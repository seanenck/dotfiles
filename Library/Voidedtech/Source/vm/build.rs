extern crate clap;

use clap::Shell;

include!("src/cli.rs");

fn main() {
    let dir = match std::env::var("COMPLETIONS") {
        Err(_) => return,
        Ok(dir) => dir,
    };
    let mut app = build_cli();
    app.gen_completions("vm",      // We need to specify the bin name manually
                        Shell::Zsh,  // Then say which shell to build completions for
                        dir);      // Then say where write the completions to
}