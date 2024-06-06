#! /usr/bin/env node

//
//  Load the packages needed for MathJax
//
const hljs = require('highlight.js')

//
//  Get the command-line arguments
//
var argv = require('yargs')
    .demand(0).strict()
    .usage('$0 [options] "code" > file.html')
    .options({
        language: {
            default: 'xml',
            describe: 'the language'
        }
    })
    .argv;


//
console.log(hljs.highlight(argv._[0], { language: argv.language }).value);