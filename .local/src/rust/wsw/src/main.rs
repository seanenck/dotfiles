extern crate clap;
extern crate pnet;
use clap::{App, Arg};
use pnet::datalink;
use std::fmt;
use std::fs;
use std::fs::OpenOptions;
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::path::Path;
use std::process;
use std::process::{Command, Stdio};
use std::thread;
use std::time::Duration;

const DEFAULT_PROFILE: &str = "default";

struct NetInterface {
    ips: Vec<String>,
    name: String,
}

impl fmt::Display for NetInterface {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "[{}:{}]", self.name, self.ips.join(","))
    }
}

struct Context {
    configs: String,
    cache: String,
    bind: String,
    url: String,
    online: String,
    host: String,
}

impl Context {
    fn current_profile(&self) -> Option<Profile> {
        if Path::new(&self.cache).exists() {
            match fs::read_to_string(&self.cache) {
                Ok(contents) => {
                    return Profile::parse(contents);
                }
                Err(e) => {
                    println!("unable to read current state: {}", e);
                }
            }
        }
        None
    }
    fn to_server(&self) -> (String, String, String, String) {
        (
            self.configs.to_owned(),
            self.cache.to_owned(),
            self.bind.to_owned(),
            self.host.to_owned(),
        )
    }
    fn from_server(configs: String, cache: String, bind: String, host: String) -> Context {
        Context {
            configs,
            cache,
            bind,
            host,
            url: "".to_string(),
            online: "".to_string(),
        }
    }
}

struct Profile {
    mode: String,
    iface: String,
    name: String,
}

impl Profile {
    fn parse(name: String) -> Option<Profile> {
        let parts: Vec<&str> = name.split('.').collect();
        match parts.len() {
            2 => {
                if parts[1] == DEFAULT_PROFILE {
                    return Some(Profile {
                        iface: parts[0].to_string(),
                        mode: "".to_string(),
                        name: DEFAULT_PROFILE.to_string(),
                    });
                }
            }
            3 => {
                return Some(Profile {
                    iface: parts[1].to_string(),
                    mode: parts[0].to_string(),
                    name: parts[2].to_string(),
                })
            }
            _ => {}
        }
        println!("invalid profile: {}", name);
        None
    }
}

impl fmt::Display for Profile {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let mode = if self.mode.is_empty() {
            String::from("")
        } else {
            format!("{}.", &self.mode)
        };
        write!(f, "{}{}.{}", mode, self.iface, self.name)
    }
}

fn command_no_output(cmd: &mut Command) -> &mut Command {
    cmd.stdout(Stdio::null()).stderr(Stdio::null())
}

fn check_online(url: String, file: String) {
    let mut good = 2;
    let mut bad = 2;
    loop {
        let mut ok = false;
        match command_no_output(Command::new("curl").arg("-s").arg(&url)).status() {
            Ok(status) => {
                ok = status.success();
            }
            Err(e) => {
                println!("curl error: {}", e);
            }
        }
        if ok {
            good += 1;
        } else {
            bad += 1;
        }
        let is_good = good >= 3;
        let is_bad = bad >= 3;
        if is_good {
            match command_no_output(Command::new("touch").arg(&file)).status() {
                Ok(_) => {}
                Err(e) => println!("unable to touch file: {}", e),
            }
        }
        if is_bad {
            match command_no_output(Command::new("rm").arg("-f").arg(&file)).status() {
                Ok(_) => {}
                Err(e) => println!("unable to rm file: {}", e),
            }
        }
        if is_good || is_bad {
            good = 0;
            bad = 0;
        }
        thread::sleep(Duration::from_secs(10));
    }
}

fn kill_now(command: String) {
    match command_no_output(Command::new("pkill").arg(command.to_string())).output() {
        Ok(_) => {}
        Err(e) => {
            println!("unable to kill {}: {}", command, e);
        }
    }
}

fn set_link(link_name: String, up: bool) {
    let op = if up { "up" } else { "down" };
    match Command::new("ip")
        .arg("link")
        .arg("set")
        .arg(link_name)
        .arg(op)
        .status()
    {
        Ok(_) => {}
        Err(e) => {
            println!("unable to set link: {}", e);
        }
    }
}

fn update(networks: String, cache: String, hostname: String, profile: Profile) {
    let interfaces = list_interfaces(false);
    let cmd = Command::new("dhclient").arg("-r").output();
    match cmd {
        Ok(_) => {}
        Err(e) => {
            println!("dhclient release error: {}", e);
        }
    }
    for iface in interfaces {
        set_link(iface.name, false);
    }
    println!("changing profile: {}", profile);
    let file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .create(true)
        .open(cache);
    match file {
        Ok(mut file_obj) => match file_obj.write(format!("{}", &profile).as_bytes()) {
            Ok(_) => {}
            Err(e) => {
                println!("state write failed: {}", e);
            }
        },
        Err(e) => {
            println!("unable to write cache: {}", e);
        }
    }
    kill_now("wpa_supplicant".to_string());
    thread::sleep(Duration::from_secs(3));
    set_link(profile.iface.to_owned(), true);
    thread::sleep(Duration::from_secs(3));
    if profile.name != DEFAULT_PROFILE {
        let profile_name = format!("{}", profile);
        let profile_iface = profile.iface.to_owned();
        let profile_mode = profile.mode.to_owned();
        thread::spawn(move || {
            run_supplicant(networks, profile_name, profile_iface, profile_mode);
        });
        thread::sleep(Duration::from_secs(3));
    }
    kill_now("dhclient".to_string());
    let dhclient_iface = profile.iface.to_owned();
    thread::spawn(move || {
        let cmd = Command::new("dhclient")
            .arg("-d")
            .arg(dhclient_iface)
            .output();
        match cmd {
            Ok(_) => {}
            Err(e) => {
                println!("dhclient acquire error: {}", e);
            }
        }
    });
    thread::sleep(Duration::from_secs(1));
    match Command::new("hostnamectl")
        .arg("set-hostname")
        .arg(hostname)
        .output()
    {
        Ok(_) => {}
        Err(e) => {
            println!("hostnamectl failed: {}", e);
        }
    }
    println!("change completed: {}", &profile);
}

fn run_supplicant(networks: String, profile_name: String, interface: String, mode_type: String) {
    let path = Path::new(&networks).join(profile_name);
    let mut mode: Vec<&str> = Vec::new();
    if mode_type == "wired" {
        mode.push("-D");
        mode.push("wired");
    }
    let cmd = Command::new("wpa_supplicant")
        .arg("-c")
        .arg(path)
        .arg("-i")
        .arg(interface)
        .args(mode)
        .output();
    match cmd {
        Ok(_) => {}
        Err(e) => {
            println!("wpa_supplicant error: {}", e);
        }
    }
}

fn change_network(ctx: &Context, profile: String) {
    let p = to_profile(ctx, profile.to_string());
    match p {
        Some(obj) => {
            update(
                ctx.configs.to_string(),
                ctx.cache.to_string(),
                ctx.host.to_string(),
                obj,
            );
        }
        None => {
            println!("invalid profile for change: {}", &profile);
        }
    }
}

fn run_monitor(config: String, cache: String, bind: String, host: String) {
    let ctx = Context::from_server(config, cache, bind, host);
    if let Some(p) = ctx.current_profile() {
        change_network(&ctx, format!("{}", p));
    }
    loop {
        match TcpListener::bind(&ctx.bind) {
            Ok(listener) => {
                for stream in listener.incoming() {
                    match stream {
                        Ok(mut data) => {
                            let mut buffer = String::new();
                            match data.read_to_string(&mut buffer) {
                                Ok(_) => {
                                    change_network(&ctx, buffer);
                                }
                                Err(e) => {
                                    println!("unable to read stream: {}", e);
                                }
                            }
                        }
                        Err(e) => {
                            println!("tcp stream error: {}", e);
                        }
                    }
                }
            }
            Err(e) => {
                println!("tcp listener issue: {}", e);
            }
        }
        thread::sleep(Duration::from_secs(1));
    }
}

fn daemonize(ctx: &Context) {
    let online_file = ctx.online.to_owned();
    let use_url = ctx.url.to_owned();
    let online = thread::spawn(move || {
        check_online(use_url, online_file);
    });
    let server = ctx.to_server();
    let monitor = thread::spawn(move || {
        run_monitor(server.0, server.1, server.2, server.3);
    });
    monitor.join().expect("monitor thread unavailable");
    online.join().expect("unable to wait for online thread");
}

fn list_interfaces(populated: bool) -> Vec<NetInterface> {
    let mut interfaces: Vec<NetInterface> = Vec::new();
    for iface in datalink::interfaces() {
        let mut has = false;
        let mut addresses: Vec<String> = Vec::new();
        for addr in iface.ips {
            if addr.is_ipv4() {
                addresses.push(addr.ip().to_string());
                has = true;
            }
        }
        if populated && !has {
            continue;
        }
        let interface = NetInterface {
            ips: addresses,
            name: iface.name,
        };
        if &interface.name == "lo" {
            continue;
        }
        interfaces.push(interface);
    }
    interfaces
}

fn show_addresses() {
    let interfaces = list_interfaces(true);
    let mut addresses: Vec<String> = Vec::new();
    for iface in interfaces {
        addresses.push(format!("{}", iface));
    }
    println!("{}", addresses.join(""));
}

fn list_profiles(ctx: &Context) -> Result<Vec<Profile>, String> {
    match fs::read_dir(&ctx.configs) {
        Ok(configs) => {
            let mut files: Vec<String> = Vec::new();
            for p in configs {
                match p {
                    Ok(file) => {
                        let fname = file.file_name();
                        match fname.into_string() {
                            Ok(s) => {
                                files.push(s);
                            }
                            Err(_) => {
                                println!("unreadable config");
                                return Err("unable to read configuration".to_string());
                            }
                        }
                    }
                    Err(e) => {
                        println!("invalid configuration: {}", e);
                        return Err("unable to read configuration".to_string());
                    }
                }
            }
            let ifaces = list_interfaces(false);
            let mut profiles: Vec<Profile> = Vec::new();
            for i in ifaces {
                let p = Profile {
                    name: DEFAULT_PROFILE.to_string(),
                    mode: "".to_string(),
                    iface: i.name.to_owned(),
                };
                profiles.push(p);
                let use_iname: &str = &i.name;
                for file in files.iter().cloned() {
                    let file_name = &file;
                    if !file_name.contains(use_iname) {
                        continue;
                    }

                    let parts: Vec<&str> = file_name.split('.').collect();
                    if parts.len() != 3 {
                        println!("invalid profile detected, skipped: {}", file_name);
                        continue;
                    }
                    let fp = Profile {
                        name: parts[2].to_string(),
                        mode: parts[0].to_string(),
                        iface: parts[1].to_string(),
                    };
                    profiles.push(fp);
                }
            }
            Ok(profiles)
        }
        Err(e) => {
            println!("unable to list profiles: {}", e);
            Err("no profiles".to_string())
        }
    }
}

fn show_profiles(ctx: &Context) {
    match list_profiles(ctx) {
        Ok(profiles) => {
            for profile in profiles {
                println!("{}", profile)
            }
        }
        Err(e) => {
            println!("unable to show profiles: {}", e);
        }
    }
}

fn to_profile(ctx: &Context, name: String) -> Option<Profile> {
    match list_profiles(ctx) {
        Ok(profiles) => {
            for profile in profiles {
                if name == format!("{}", profile) {
                    return Some(profile);
                }
            }
            println!("unable to load profile: {}", name);
        }
        Err(e) => {
            println!("unable to load profile list: {}", e);
        }
    }
    None
}

fn load_profile(ctx: &Context, name: String) {
    if to_profile(ctx, name.to_string()).is_some() {
        let stream = TcpStream::connect(&ctx.bind);
        match stream {
            Ok(mut data) => match data.write(name.to_string().as_bytes()) {
                Ok(_) => {}
                Err(e) => {
                    println!("unable to write to stream: {}", e);
                }
            },
            Err(e) => {
                println!("unable to connect: {}", e);
            }
        }
    }
}

fn main() {
    let matches = App::new("wsw")
        .arg(
            Arg::with_name("networks")
                .short("n")
                .long("networks")
                .help("location of network configuration files")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("mode")
                .short("m")
                .long("mode")
                .help("operating mode")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("profile")
                .help("profile name")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("url")
                .short("u")
                .long("url")
                .help("url for online checking")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("bind")
                .short("b")
                .long("bind")
                .help("socket to bind for communication")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("cache")
                .short("c")
                .long("cache")
                .help("caching location")
                .takes_value(true),
        )
        .get_matches();
    let mode = matches.value_of("mode").unwrap_or("profile");
    let cache = matches
        .value_of("cache")
        .unwrap_or("/var/cache/wsw")
        .to_string();
    let mut hostname = String::new();
    match fs::read_to_string("/etc/hostname") {
        Ok(contents) => {
            hostname.push_str(contents.trim());
        }
        Err(e) => {
            panic!("unable to read hostname: {}", e);
        }
    };
    let ctx = Context {
        host: hostname.to_string(),
        bind: matches
            .value_of("bind")
            .unwrap_or("127.0.0.1:6789")
            .to_string(),
        cache: cache.to_string(),
        url: matches
            .value_of("url")
            .unwrap_or("https://duckduckgo.com")
            .to_string(),
        configs: matches
            .value_of("networks")
            .unwrap_or("/etc/wsw/")
            .to_string(),
        online: format!("{}.online", cache),
    };
    match mode {
        "profile" | "reload" => {
            let mut profile = matches.value_of("profile").unwrap_or("").to_string();
            if mode == "reload" {
                match ctx.current_profile() {
                    Some(p) => {
                        profile = format!("{}", p);
                    }
                    None => {
                        profile = "".to_string();
                    }
                }
            }
            if profile != "" {
                load_profile(&ctx, profile);
            }
        }
        "daemon" => {
            daemonize(&ctx);
        }
        "addr" => {
            show_addresses();
        }
        "online" => {
            let exit = if Path::new(&ctx.online).exists() {
                0
            } else {
                1
            };
            process::exit(exit);
        }
        "list" => {
            show_profiles(&ctx);
        }
        "current" => {
            if let Some(p) = ctx.current_profile() {
                println!("{}", p);
            }
        }
        _ => {}
    }
}
