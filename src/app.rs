use clap::{App, Arg};

pub fn build_app() -> App<'static, 'static> {
    let app: App<'static, 'static> = App::new("yew-cli")
        .about("CLI-program for Yew-rs Web Framework.")
        .author("Josh Fourie <josh@aequita.io>")
        .version("1.0")
        .subcommand(
            App::new("new")
                .about("Creates a new yew-rs project for the web.")
                .author("Josh Fourie <josh@aequita.io>")
                .version("1.0")
                .arg(
                    Arg::with_name("name")
                        .short("n")
                        .long("name")
                        .help("Sets the name for the project.")
                        .takes_value(true)
                        .value_name("PROJECT_NAME")
                        .required(true)
                )
                .arg(
                    Arg::with_name("outdir")
                        .short("o")
                        .long("out")
                        .help("Sets the directory to initialise the project.")
                        .takes_value(true)
                        .value_name("DIRECTORY")
                )
        );
    app
}