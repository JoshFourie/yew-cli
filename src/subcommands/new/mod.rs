use clap::ArgMatches;

use std::{process, fs, io};
use process::{Command, Output};
use fs::{File, OpenOptions};

use crate::YewSubcommand;

const OUTDIR: &'static str = "./";

const CARGO: &'static str = "src/subcommands/new/cargo.config";
const LIB: &'static str = "src/subcommands/new/lib.config";
const E2E: &'static str = "src/subcommands/new/e2e.config";
const PKG: &'static str = "src/subcommands/new/package.config";


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

    fn run(self) -> Result<(), io::Error> {
        self.new_lib()?
            .copy_rust()?
            .add_protractor()?
            .update_webdriver()?
            .make_e2e()?
            .copy_package()?;
        Ok(())
    }
}

impl<'a> NewProject<'a> {
    fn new_lib(&self) -> io::Result<&Self> {
        let status: _ = Command::new("cargo")
            .args(&["new", "--lib", "--name", self.name, self.outdir])
            .output()?
            .status;
        if status.success() {
            Ok(self)
        } else { panic!("{}", status) }
    }

    fn copy_rust(&self) -> io::Result<&Self> {
        let cargo_dest: String = format!("{}/Cargo.toml", self.outdir);
        write(CARGO, cargo_dest, true)?;
    
        let lib_dest: String = format!("{}/src/lib.rs", self.outdir);
        write(LIB, lib_dest, false)?;

        Ok(self)
    }

    fn add_protractor(&self) -> io::Result<&Self> {
        let status: _ = Command::new("yarn")
            .args(&["--cwd", self.outdir, "add", "protractor"])
            .output()?
            .status;
        if status.success() {
            Ok(self)
        } else { panic!("{}", status) }
    }    

    fn update_webdriver(&self) -> io::Result<&Self> {
        let status: _ = Command::new("yarn")
            .args(&["--cwd", self.outdir, "run", "webdriver-manager", "update"])
            .output()?
            .status;
        if status.success() {
            Ok(self)
        } else { panic!("{}", status) }
    }

    fn make_e2e(&self) -> io::Result<&Self> {
        let e2e_dir: String = format!("{}/e2e", self.outdir);
        fs::create_dir_all(e2e_dir)?;
    
        let spec_path: String = format!("{}/e2e/spec.conf.js", self.outdir);
        write(E2E, spec_path, false)?;
        
        Ok(self)
    }

    fn copy_package(&self) -> io::Result<&Self> {
        let package_path: String = format!("{}/package.json", self.outdir);
        write(PKG, package_path, false)?;
        Ok(self)
    }
}

fn write(src: &str, dest: String, append: bool) -> io::Result<u64> {
    let mut src: File = OpenOptions::new()
        .read(true)
        .open(src)?;

    let mut dest: File = OpenOptions::new()
        .create(true)
        .append(append)
        .write(!append)
        .open(dest)?;

    io::copy(&mut src, &mut dest)
}
