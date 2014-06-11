svg-def-cleaner
===============

Detect and merge redundant definitions for lighter svg files

How to use
----------
First step, installation.
Be sure to have node.js installed on your system then :
```sh
npm install -g svg-dev-cleaner
```

To clean a svg file juste write in your shell :
```sh
svg-dev-cleaner inputFile.svg outputFile.svg
```

To use it as module :
```javascript
var sdc = require('svg-def-cleaner');
// string api
var cleanedSvgString = sdc.cleanSvgContent('<xml>redundantSvg</xml>');
// file api
sdc.main('sourceFile.svg', 'targetFile.svg');
```


How to contribute
-----------------
You need node.js and git then run :
```sh
git clone git@github.com:GammaNu/svg-def-cleaner.git
cd svg-def-cleaner
npm install
node_modules/coffee-script/bin/cake watch
```
start codding !