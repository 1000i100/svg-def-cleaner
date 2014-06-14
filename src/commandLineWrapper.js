#!/usr/bin/env node
if(process.argv.length != 4) return console.error('Usage : svg-def-cleaner sourceFile targetFile');

var sdc = require('./svg-def-cleaner');
sdc.main(process.argv[2], process.argv[3]);
