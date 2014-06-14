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
scope.getId = (string)-> string.match(/id="([^"]*)"/)[1]
scope.removeId = (string)-> string.replace /id="([^"]*)"/, 'id=""'
scope.injectId = (id, string)-> string.replace /id=""/, 'id="'+id+'"'
scope.removeDuplicateDef = (duplicateString, fileContent)-> fileContent.replace duplicateString, ''

scope.listIdNodes = (string)->
	domRoot = new domParser().parseFromString('<defs>'+string+'</defs>')
	nodes = xpath.select("//*[@id]", domRoot)
	node.toString() for node in nodes

scope.mapRedudency = (list)->
	map = {}
	for element in list
		do (element)->
			key = scope.removeId element
			value = scope.getId element
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
	redundancyMap = scope.cleanUnduplicated scope.mapRedudency scope.listIdNodes scope.getDefs fileContent
	for redundantDef, occurrence of redundancyMap
		do (redundantDef, occurrence)->
			canonicalId = occurrence.shift()
			for redundantId in occurrence
				do (redundantId)->
					fileContent = scope.removeDuplicateDef scope.injectId(redundantId, redundantDef), fileContent
					fileContent = scope.fixLink(canonicalId, redundantId, fileContent)
	return fileContent
