fs = require 'fs'
encoding = 'utf8'

scope = exports ? this
scope.main = (sourceFile, targetFile) ->
	'TODO'

scope.loadFile = (fileName)->
	fileContent = fs.readFileSync fileName
	fileContent.toString(encoding)
scope.writeFile = (fileName, content)-> fs.writeFileSync fileName, content, {'encoding':encoding}
scope.getDefs = (string)-> string.replace /([\s\S]*)<defs[^>]*>([\s\S]*)<\/defs>([\s\S]*)/im, '$2'
scope.getId = (string)-> string.match(/id="([^"]*)"/)[1]
scope.removeId = (string)-> string.replace /id="([^"]*)"/, 'id=""'
scope.injectId = (id, string)-> string.replace /id=""/, 'id="'+id+'"'
scope.removeDuplicateDef = (duplicateString, fileContent)-> fileContent.replace duplicateString, ''

#scope.listIdNodes = (string)-> string.match /<[^ >]+\1 [^>]*id=[^>]*>[^<]*((<[^>]+>)*[^<]*)<\/\1>/gm
scope.listIdNodes = (string)-> string.match /<([^ >]+\1) [^>]*id=[^>]*>[\s\S]*<\/\1>/gm
scope.getFirstNodeWithoutChild  = (string)-> string.match(/<([^ >]+\1)( [^>]+)*>[^<]*<\/\1>/m)[0]
scope.listNodesWithoutChild  = (string)-> string.match /<([^ >]+\1)( [^>]+)*>[^<]*<\/\1>/gm

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
	console.log(redundancyMap)
	for redundantDef, occurrence of redundancyMap
		do (redundantDef, occurrence)->
			canonicalId = occurrence.shift()
			for redundantId in occurrence
				do (redundantId)->
					fileContent = scope.removeDuplicateDef scope.injectId(redundantId, redundantDef), fileContent
					fileContent = scope.fixLink(canonicalId, redundantId, fileContent)
	return fileContent

#scope.cleanSvgContent	'<defs><b id="b">b</b><b id="ccc">b</b><d id="d">d</d><d id="e">d</d></defs><osef xlink:href="#b"/><osef xlink:href="#ccc" style="background:url(#ccc) #ccc" filter="url(#ccc)'