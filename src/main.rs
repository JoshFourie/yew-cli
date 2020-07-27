mod subcommands;
use subcommands::NewProject;

mod app;

use clap::{App, ArgMatches};

use std::io;

trait YewSubcommand<'a> {
    fn new(args: &'a ArgMatches) -> Self;

    fn run(self) -> io::Result<()>;
}

fn main() {
    let app: App<'static, 'static> = app::build_app();
    let matches: ArgMatches = app.get_matches();

    match matches.subcommand() {
        ("new", cmd) => {
            match cmd {
                Some(args) => NewProject::new(args).run().unwrap(),
                None => todo!()
            }
        },
        ("build", cmd) => {
            println!("building project.")

        },
        ("add", cmd) => {
            println!("adding new component.")
        },
        _ => {
            println!("command not provided.")
        }
    }
}