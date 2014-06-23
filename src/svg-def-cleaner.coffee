fs = require 'fs'
xpath = require 'xpath'
domParser = require('xmldom').DOMParser

encoding = 'utf8'

scope = exports ? this
scope.main = (sourceFile, targetFile) ->
	sourceContent = scope.loadFile sourceFile
	cleanedContent = scope.cleanSvgContent sourceContent
	scope.writeFile targetFile, cleanedContent.replace /\r?\n|\r/g, ''


scope.loadFile = (fileName)->
	fileContent = fs.readFileSync fileName
	fileContent.toString(encoding)
scope.writeFile = (fileName, content)-> fs.writeFileSync fileName, content, {'encoding':encoding}
scope.getDefs = (string)-> string.replace /([\s\S]*)<defs[^>]*>([\s\S]*)<\/defs>([\s\S]*)/im, '$2'
scope.getAttrValue = (string,attr)->string.match(RegExp attr+'="([^"]*)"')[1]
scope.removeAttrContent = (string, attr)-> string.replace RegExp(attr+'="([^"]*)"'), attr+'=""'
scope.injectId = (id, string)-> scope.injectAttrContent string, 'id', id
scope.injectAttrContent = (string, attr, content)-> string.replace attr+'=""', attr+'="'+content+'"'
scope.removeDuplicateDef = (duplicateString, fileContent)-> fileContent.replace duplicateString, ''


scope.listNodesWithAttr = (string, attr)->
	domRoot = new domParser().parseFromString('<root_node>'+string+'</root_node>')
	nodes = xpath.select("//*[@"+attr+"]", domRoot)
	node.toString() for node in nodes
scope.listIdNodes = (string)->
	scope.listNodesWithAttr string, 'id'
scope.mapRedundancyExceptAttr = (list, attr)->
	map = {}
	for element in list
		do (element)->
			key = scope.removeAttrContent element, attr
			value = scope.getAttrValue element, attr
			if !map[key]
				map[key] = [value]
			else
				map[key].push value
	return map

scope.cleanUnduplicated = (map)->
	newMap = {}
	for key, occurrence of map
		do (key, occurrence)->
			if occurrence.length != 1
				newMap[key] = occurrence
	return newMap

scope.fixLink = (canonicalId, redundantId, fileContent)->
	pattern1 = new RegExp('url[(]#'+redundantId+'[)]','g')
	pattern2 = new RegExp('href="#'+redundantId+'"','g')
	fileContent
		.replace(pattern1, 'url(#'+canonicalId+')')
		.replace(pattern2, 'href="#'+canonicalId+'"')

scope.cleanSvgContent = (fileContent)->
	identifiedDef = scope.listIdNodes scope.getDefs fileContent
	redundancyMap = scope.cleanUnduplicated scope.mapRedundancyExceptAttr identifiedDef,'id'
	for redundantDef, occurrence of redundancyMap
		do (redundantDef, occurrence)->
			canonicalId = occurrence.shift()
			for redundantId in occurrence
				do (redundantId)->
					fileContent = scope.removeDuplicateDef scope.injectAttrContent(redundantDef, 'id', redundantId), fileContent
					fileContent = scope.fixLink(canonicalId, redundantId, fileContent)
	return fileContent
