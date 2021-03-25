extern crate clap;
use clap::{App, Arg};
use serde::{Deserialize, Serialize};
use std::env::current_dir;
use std::fs;
use std::path::Path;
use std::process::{exit, Command};
use std::thread;
use std::time;

#[derive(Debug, PartialEq, Serialize, Deserialize)]
struct MountOptions {
    size: String,
    file: String,
    enable: bool,
}

#[derive(Debug, PartialEq, Serialize, Deserialize)]
struct Machine {
    memory: u32,
    root: String,
    kernel: String,
    initrd: String,
    disk: String,
    params: String,
    tty: String,
    mount: MountOptions,
}

fn start_vm(tool: String, vm: Machine) {
    thread::spawn(move || {
        let mut cmd = Command::new(tool.to_owned());
        cmd.arg("-k");
        cmd.arg(vm.kernel);
        cmd.arg("-i");
        cmd.arg(vm.initrd);
        cmd.arg("-m");
        cmd.arg(vm.memory.to_string());
        cmd.arg("-d");
        cmd.arg(vm.disk);
        cmd.arg("-a");
        cmd.arg(vm.params);
        cmd.arg("-y");
        cmd.arg(vm.tty);
        if vm.mount.enable {
            cmd.arg("-d");
            cmd.arg(vm.mount.file);
        }
        cmd.current_dir(vm.root);
        match cmd.output() {
            Ok(_) => {}
            Err(e) => {
                println!("unable to run command: {}", e);
            }
        }
    });
}

fn load_config(config: &str) -> Option<Machine> {
    match fs::read_to_string(config) {
        Ok(data) => {
            let machine = serde_yaml::from_str::<Machine>(&data);
            match machine {
                Ok(m) => {
                    return Some(m);
                }
                Err(e) => println!("failed to parse config: {}", e.to_string()),
            }
        }
        Err(e) => println!("failed to load config: {}", e.to_string()),
    }
    return None;
}

fn get_cwd() -> Option<String> {
    let env = current_dir();
    match env {
        Ok(d) => match d.into_os_string().into_string() {
            Ok(s) => {
                return Some(s);
            }
            Err(_) => {
                println!("unable to read cwd");
            }
        },
        Err(e) => {
            println!("unable to get cwd: {}", e);
        }
    }
    None
}

fn main() {
    let matches = App::new("vm")
        .version("1.0")
        .arg(
            Arg::with_name("config")
                .long("config")
                .value_name("CONFIG")
                .help("vm configuration file")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("vftool")
                .long("vftool")
                .value_name("VFTOOL")
                .help("vftool path")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("root")
                .long("root")
                .value_name("ROOT")
                .help("root path")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("timeout")
                .long("timeout")
                .value_name("TIMEOUT")
                .help("timeout waiting for tty")
                .takes_value(true),
        )
        .get_matches();
    let timeout_raw = matches.value_of("timeout").unwrap_or("5");
    let timeout = match timeout_raw.parse::<u64>() {
        Ok(v) => v,
        Err(e) => {
            println!("unable to parse timeout: {}", e);
            exit(1);
        }
    };
    let root = matches.value_of("root").unwrap_or("/Users/enck/VM/");
    let default_cfg = root.to_owned() + "vm.yaml";
    let cfg = matches.value_of("config").unwrap_or(default_cfg.as_str());
    let default_tool = root.to_owned() + "vftool/build/vftool";
    let tool = matches.value_of("vftool").unwrap_or(default_tool.as_str());
    let machine = load_config(cfg);
    if machine == None {
        exit(1);
    }
    let vm = machine.unwrap();
    let tty_file = Path::new(&vm.root.to_string()).join(&vm.tty.to_string());
    if tty_file.exists() {
        match fs::remove_file(&tty_file) {
            Ok(_) => {}
            Err(e) => {
                println!("unable to remove tty file: {}", e);
                exit(1);
            }
        }
    }
    if vm.mount.enable {
        let mut dmg = String::new();
        dmg.push_str(&vm.mount.file.to_string());
        dmg.push_str(".dmg");
        let path = Path::new(&vm.root.to_string()).join(dmg.as_str());
        if path.exists() {
            match fs::remove_file(path) {
                Ok(_) => {}
                Err(e) => {
                    println!("unable to delete old mount file: {}", e);
                    exit(1);
                }
            }
        }
        let work_dir = get_cwd();
        match work_dir {
            Some(val) => {
                let cmd = Command::new("hdiutil")
                    .arg("create")
                    .arg(&vm.mount.file)
                    .arg("-size")
                    .arg(&vm.mount.size)
                    .arg("-srcfolder")
                    .arg(&val)
                    .arg("-fs")
                    .arg("exFAT")
                    .arg("-format")
                    .arg("UDRW")
                    .current_dir(&vm.root)
                    .status()
                    .expect("hdiutil failed");
                if !cmd.success() {
                    println!("hdiutil unable to make image");
                }
            }
            None => {
                exit(1);
            }
        }
    }
    start_vm(tool.to_owned(), vm);
    manage(timeout, tty_file);
    match Command::new("killall").arg("vftool").status() {
        Ok(_) => {}
        Err(e) => {
            println!("unable to kill vftool: {}", e);
        }
    }
}

fn manage(timeout: u64, tty_file: std::path::PathBuf) {
    let duration = time::Duration::from_secs(timeout);
    thread::sleep(duration);
    if !tty_file.exists() {
        println!("tty file not found");
        return;
    }
    match fs::read_to_string(tty_file) {
        Ok(data) => match Command::new("screen").arg(data.trim()).status() {
            Ok(_) => {}
            Err(e) => {
                println!("unable to attach: {}", e);
                return;
            }
        },
        Err(e) => {
            println!("unable to read tty file: {}", e);
            return;
        }
    }
}
