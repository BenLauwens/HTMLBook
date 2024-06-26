#! /usr/bin/env node

/*************************************************************************
 *
 *  direct/tex2mml-page
 *
 *  Uses MathJax v3 to convert all TeX in an HTML document to MathML.
 *
 * ----------------------------------------------------------------------
 *
 *  Copyright (c) 2020 The MathJax Consortium
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
const { mathjax } = require('mathjax-full/js/mathjax.js');
const { TeX } = require('mathjax-full/js/input/tex.js');
const { RegisterHTMLHandler } = require('mathjax-full/js/handlers/html.js');
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
        em: {
            default: 16,
            describe: 'em-size in pixels'
        },
        packages: {
            default: packages.sort().join(', '),
            describe: 'the packages to use, e.g. "base, ams"'
        }
    })
    .argv;

//
//  Read the HTML file
//
const htmlfile = require('fs').readFileSync(argv._[0], 'utf8');

//
//  Create DOM adaptor and register it for HTML documents
//
const adaptor = liteAdaptor({ fontSize: argv.em });
const handler = RegisterHTMLHandler(adaptor);

//
//  Create a MathML serializer
//
const { SerializedMmlVisitor } = require('mathjax-full/js/core/MmlTree/SerializedMmlVisitor.js');
const visitor = new SerializedMmlVisitor();
const toMathML = (node => visitor.visitTree(node, html));

//
//  A renderAction to take the place of typesetting.
//  It renders the output to MathML instead.
//
function actionMML(math, doc) {
    const adaptor = doc.adaptor;
    const mml = toMathML(math.root);
    math.typesetRoot = adaptor.firstChild(adaptor.body(adaptor.parse(mml, 'text/html')));
}

//
//  Create an HTML document using the html file and a new TeX input jax
//
const html = mathjax.document(htmlfile, {
    renderActions: {
        typeset: [150, (doc) => { for (const math of doc.math) actionMML(math, doc) }, actionMML]
    },
    InputJax: new TeX({ packages: argv.packages.split(/\s*,\s*/) })
});

//
//  Render the document and print the results
//
html.render();
console.log(adaptor.doctype(html.document));
console.log(adaptor.outerHTML(adaptor.root(html.document)));