extern crate clap;
use clap::{App, Arg};
use serde::{Deserialize, Serialize};
use std::env::current_dir;
use std::fs;
use std::io::Read;
use std::path::Path;
use std::process::{exit, Command, Stdio};
use std::sync::mpsc::{channel, Sender};
use std::thread;

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
    mount: MountOptions,
}

fn start_vm(tool: String, vm: Machine, sender: Sender<String>) {
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
        if vm.mount.enable {
            cmd.arg("-d");
            cmd.arg(vm.mount.file);
        }
        cmd.current_dir(vm.root);
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
            Err(e) => {
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
        .get_matches();
    let root = matches.value_of("root").unwrap_or("/Users/enck/VM/");
    let default_cfg = root.to_owned() + "vm.yaml";
    let cfg = matches.value_of("config").unwrap_or(default_cfg.as_str());
    let default_tool = root.to_owned() + "vftool/build/vftool";
    let tool = matches.value_of("vftool").unwrap_or(default_tool.as_str());
    let machine = load_config(cfg);
    if machine == None {
        exit(1);
    }
    let (sender, receiver) = channel::<String>();
    let vm = machine.unwrap();
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
    start_vm(tool.to_owned(), vm, sender);
}
