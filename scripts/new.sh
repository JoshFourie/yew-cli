#!/bin/bash

set -e

#----------- initialise variables ------------#
name=''
nset=false

outdir='static'
rootdir='.'

#----------- assign variables ------------#
print_usage() 
{
  printf "
yew-new: creates a new yew-rs project.

OPTIONS:
  -h    prints this help page
  -n    sets the name for the project (required)
  -o    sets the outdir for the wasm build (default './static')
  -r    sets the root directory for the project (default '.') 

"
}

while getopts 'hn:o:r:' flag; do 
    case "${flag}" in
      h) print_usage; exit;;
      n) name=${OPTARG}; nset=true;;
      o) outdir=${OPTARG};;
      r) rootdir=${OPTARG};;
    esac
done

run() 
{
  check_runtime

  mkdir -p $rootdir
  cd $rootdir
  
  make_rust
  make_protractor
  
  edit_package
}

#----------- cargo ------------#
check_runtime()
{
  if ! $nset
  then
      print_usage
      printf "\nError: missing required argument [ -n <PROJECT_NAME> ]\n\n"
      exit
  fi
}


#----------- cargo ------------#
make_rust()
{
  cargo init --lib --name $name

  printf "\
wasm-bindgen = \"0.2.65\"
yew = \"0.17.2\"

[lib]
crate-type = [\"cdylib\", \"rlib\"]

" >> Cargo.toml

  printf "\
use wasm_bindgen::prelude::*;
use yew::prelude::*;

#[wasm_bindgen(start)]
pub fn entrypoint() {
  // App::<SOME_COMPONENT>::new().mount_to_body();
}

  " > src/lib.rs
}


#----------- protractor ------------#
make_protractor()
{
  yarn add protractor
  yarn run webdriver-manager
  yarn run webdriver-manager update

  mkdir -p e2e

  printf "\
exports.config = {
  directConnect: true,
  specs: [

  ],
  capabilities: {
    browserName: 'chrome',
    chromeOptions: {
      args: [\"--headless\", \"--disable-dev-shm-usage\"]
    }
  },
};

" > e2e/spec.conf.js
}

#----------- package.json ------------#
edit_package()
{
  printf "\
{
  \"name\": "\"$name\"",
  \"scripts\": {
      \"test\": \"protractor e2e/spec.conf.js\",
      \"serve\": \"miniserve static/ --index index.html\" 
  }
}

" > package.json
}

run