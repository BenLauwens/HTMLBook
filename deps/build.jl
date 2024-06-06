# install NodeJS modules
using NodeJS

run(Cmd(`$(npm_cmd()) install --scripts-prepend-node-path=true --production --no-package-lock --no-optional mathjax-full@3 yargs highlight.js pagedjs-cli pagedjs`, dir=@__DIR__))
