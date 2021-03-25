use clap::{App, Arg};

pub fn build_cli() -> App<'static, 'static> {
    App::new("vm")
        .version("1.0")
        .arg(
            Arg::with_name("config")
                .long("config")
                .value_name("CONFIG")
                .help("vm configuration file")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("vm")
                .long("vm")
                .value_name("VMPATH")
                .help("vm root path")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("timeout")
                .long("timeout")
                .value_name("TIMEOUT")
                .help("timeout waiting for tty")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("mount")
                .long("mount")
                .help("mount the directory")
                .takes_value(false),
        )
}