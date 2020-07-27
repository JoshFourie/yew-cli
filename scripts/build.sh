#!/bin/bash

set -e

#----------- initialise variables ------------#
outdir='static'
yewdir='.'
rootdir='.'

#----------- assign variables or print help ------------#
print_usage() 
{
  printf "
yew-new: compiles a new yew-rs project into the web target.

OPTIONS:
    -h      prints this help page
    -o      sets the outdir for the wasm build (default './static')
    -r      sets the root directory for your yew project (default './src')

"
}

while getopts 'o:r:n:ht:' flag; do
    case "${flag}" in 
        o) outdir=${OPTARG};;
        r) rootdir=${OPTARG};;
        n) name=${OPTARG};;
        h) print_usage; exit;;
        t) title=${OPTARG};;
    esac
done

#----------- assign variables or print help ------------#
run()
{
    mkdir -p $rootdir
    cd $rootdir

    name=$(grep name Cargo.toml | sed -e 's/name\s*=\s*\"\(.*\)"/\1/')

    make_build
    copy_css
    copy_img
    build_wasm
}


#----------- find css and move into global style sheet ------------#
copy_css()
{
    truncate -s 0 $outdir/style.css
    cat $(find $yewdir -depth -iname *.css) > $outdir/style.css
}

#----------- find img and move into global style sheet ------------#
copy_img()
{
    find $yewdir/src -depth -type d -name assets -exec cp -r {} $outdir/ \;
}

#----------- make wasm files ------------#
make_build()
{
    rm -rf $outdir
    mkdir $outdir

    touch $outdir/style.css

  printf "
<!doctype html>
<html lang=\"en\">
    <head>
        <meta charset=\"utf-8\">
        <title>${title^}</title>
        <script type=\"module\">
            import init from \"./$name.js\"
            init()
        </script>

        <link rel=\"stylesheet\" href=\"https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css\" integrity=\"sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk\" crossorigin=\"anonymous\">
        <link href=\"https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,500,600,700,700i|Montserrat:300,400,500,600,700\" rel=\"stylesheet\">
        <link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">

        <script src=\"https://use.fontawesome.com/633d363f24.js\"></script>
        <script src=\"https://code.jquery.com/jquery-3.5.1.slim.min.js\" integrity=\"sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj\" crossorigin=\"anonymous\"></script>
        <script src=\"https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js\" integrity=\"sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo\" crossorigin=\"anonymous\"></script>
        <script src=\"https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js\" integrity=\"sha384-OgVRvuATP1z7JjHLkuOU7Xw704+h835Lr+6QL9UvYjZE3Ipu6Tp75j7Bh/kR0JKI\" crossorigin=\"anonymous\"></script>

        <link rel=\"icon\" 
            href=\"./assets/favicon.ico\">
    </head>
    <body></body>
</html>

" > $outdir/index.html
}

#----------- find css and move into global style sheet ------------#
build_wasm()
{
    cd $yewdir
    wasm-pack build --out-name $name --out-dir $outdir --target web
}


run
