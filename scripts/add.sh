#!/bin/bash

set -e

#----------- initialise variables ------------#
name=''
nset=false

parent='src/lib.rs'
dirpath='./'

#----------- assign variables ------------#
print_usage() 
{
    printf "
yew-add: adds a new yew-rs component to an existing project.

OPTIONS:
    -n      sets the name of the component (required)
    -p      sets the parent module of the new component (default 'lib.rs') [ NOTE: prefer the default and do not pass lib.rs as an argument ]
    -h      prints this help page
    -r    sets the root directory for the project (default '.') 


"
}

while getopts 'n:p:hr:' flag; do 
    case "${flag}" in
        n) name=${OPTARG}; nset=true;;
        p) parent=src/${OPTARG}/mod.rs;;
        h) print_usage; exit;;
        r) rootdir=${OPTARG};;
    esac
done

run() 
{
    check_runtime

    mkdir -p $rootdir
    cd $rootdir

    dirpath=$(dirname $parent)/$name # e.g. src/header

    make_dir
    make_component
    make_test
    make_specs
    make_css

    edit_parent
}

#----------- check required arguments are set ------------#
check_runtime()
{
    if ! $nset
    then
        print_usage
        printf "\nError: missing required argument [ -n <COMPONENT_NAME> ]\n\n"
        exit
    fi
}


#----------- make directory and set dirpath ------------#
make_dir() 
{
    mkdir -p $dirpath 
}


#----------- make and edit files for new component ------------#
make_specs() 
{
    printf "\
describe('${name^} Protractor Tests', function() {

    // one-time set-up.
    browser.waitForAngularEnabled(false);
    var browserURL = 'http://127.0.0.1:8080'

    // repeated set-up
    beforeEach(function() {
        browser.get(browserURL);
    })

    it(' ', () => {

    })
});

" > $dirpath/$name.spec.js

    sed -i "/specs: /a \    \'../$dirpath/$name.spec.js\'," e2e/spec.conf.js 
}


make_test()
{
    printf "\
#[test]
fn it_works() {
    assert_eq!(2 + 2, 4);
}

" > $dirpath/test_$name.rs
}


make_css() 
{
    printf "
@keyframes $name-component-animation {
    
}

.$name-component {

}

" > $dirpath/$name.css
}


make_component() 
{
    printf "\
#[cfg(test)] mod test_$name;

use yew::prelude::*;
use std::fmt::{Display, Formatter, Result as FormatResult};


#[derive(Copy, Clone, Debug)]
pub enum ${name^}Message { }

#[derive(Properties, Clone, Debug, Default)]
pub struct ${name^}Properties { }

impl Display for ${name^}Properties {
    fn fmt(&self, f: &mut Formatter<'_>) -> FormatResult {
        write!(f, \"\")  
    }
}

#[derive(Clone, Debug)]
pub struct ${name^}Component {
    properties: ${name^}Properties,
    link: ComponentLink<Self>
}

impl Component for ${name^}Component {
    type Message = ${name^}Message;
    type Properties = ${name^}Properties;

    fn create(properties: Self::Properties, link: ComponentLink<Self>) -> Self {
        Self { properties, link }
    }

    fn view(&self) -> Html {
        html! {
            <div class={ \"$name-component\" } style={ &self.properties }>
                <p>{ \"${name^}Component Works!\" }</p>
            </div>
        }
    }

    fn update(&mut self, msg: Self::Message) -> ShouldRender {
        false
    }

    fn change(&mut self, properties: Self::Properties) -> ShouldRender {
        false
    }
}

" > $dirpath/mod.rs
}


edit_parent() 
{
    printf "mod $name; \n\n$(cat $parent)" > $parent
}

run
