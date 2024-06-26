#! /usr/bin/env node

/*************************************************************************
 *
 *  direct/tex2mml
 *
 *  Uses MathJax v3 to convert a TeX string to a MathML string.
 *
 * ----------------------------------------------------------------------
 *
 *  Copyright (c) 2018 The MathJax Consortium
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

//
//  Load the packages needed for MathJax
//
const { TeX } = require('mathjax-full/js/input/tex.js');
const { HTMLDocument } = require('mathjax-full/js/handlers/html/HTMLDocument.js');
const { liteAdaptor } = require('mathjax-full/js/adaptors/liteAdaptor.js');
const { STATE } = require('mathjax-full/js/core/MathItem.js');

const { AllPackages } = require('mathjax-full/js/input/tex/AllPackages.js');

//
//  Busproofs requires an output jax, which we aren't using
//
const packages = AllPackages.filter((name) => name !== 'bussproofs');

//
//  Get the command-line arguments
//
var argv = require('yargs')
    .demand(0).strict()
    .usage('$0 [options] "math" > file.html')
    .options({
        inline: {
            boolean: true,
            describe: "process as inline math"
        },
        packages: {
            default: packages.sort().join(', '),
            describe: 'the packages to use, e.g. "base, ams"'
        }
    })
    .argv;

//
//  Create the input jax
//
const tex = new TeX({ packages: argv.packages.split(/\s*,\s*/) });

//
//  Create an HTML document using a LiteDocument and the input jax
//
const html = new HTMLDocument('', liteAdaptor(), { InputJax: tex });

//
//  Create a MathML serializer
//
const { SerializedMmlVisitor } = require('mathjax-full/js/core/MmlTree/SerializedMmlVisitor.js');
const visitor = new SerializedMmlVisitor();
const toMathML = (node => visitor.visitTree(node, html));

//
//  Convert the math from the command line to serialzied MathML
//
console.log(toMathML(html.convert(argv._[0] || '', { display: !argv.inline, end: STATE.CONVERT })));