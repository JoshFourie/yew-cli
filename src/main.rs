use clap::{App, ArgMatches, load_yaml};

fn main() {
    let yaml: _ = load_yaml!("cli.yaml");
    let app: ArgMatches = App::from(yaml).get_matches();

    match app.subcommand() {
        ("add", cmd) => {
            println!("adding component.")
        },
        ("build", cmd) => {
            println!("building project.")

        },
        ("new", cmd) => {
            println!("adding new project.")
        },
        _ => {
            println!("command not provided.")
        }
    }
}