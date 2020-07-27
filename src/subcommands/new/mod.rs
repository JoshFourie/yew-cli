use clap::ArgMatches;

use std::{process, fs, io};
use process::Command;
use fs::{File, OpenOptions};

use crate::YewSubcommand;

const OUTDIR: &'static str = "./";
const CARGO_CONFIG: &'static str = "src/subcommands/new/cargo.config";
const LIB_CONFIG: &'static str = "src/subcommands/new/lib.config";

pub struct NewProject<'a> {
    outdir: &'a str,
    name: &'a str
}

impl<'a> YewSubcommand<'a> for NewProject<'a> {
    fn new(args: &'a ArgMatches) -> Self {
        let outdir: &'a str = args.value_of("outdir").unwrap_or_else(|| OUTDIR);
        let name: &'a str = args.value_of("name").expect("infallible: required argument");
        
        Self {
            outdir,
            name
        }
    }

    fn run(self) {
        Command::new("cargo")
            .args(&["new", "--lib", "--name", self.name, self.outdir])
            .output()
            .unwrap();

        let cargo_dest: String = format!("{}/Cargo.toml", self.outdir);
        write(CARGO_CONFIG, cargo_dest, true).unwrap();
        
        let lib_dest: String = format!("{}/src/lib.rs", self.outdir);
        write(LIB_CONFIG, lib_dest, false).unwrap();
    }
}

fn write(src: &str, dest: String, append: bool) -> io::Result<u64> {
    let mut src: File = OpenOptions::new()
        .read(true)
        .open(src)?;

    let mut dest: File = OpenOptions::new()
        .append(append)
        .write(!append)
        .open(dest)?;

    io::copy(&mut src, &mut dest)
}
