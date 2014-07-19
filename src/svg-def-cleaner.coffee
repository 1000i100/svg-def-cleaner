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
	return scope.cleanSvgTransform scope.cleanSvgDefContent fileContent
scope.cleanSvgDefContent = (fileContent)->
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
scope.cleanSvgTransform = (fileContent)->
	transformNodes = scope.listNodesWithAttr fileContent, 'transform'
	redundancyMap = scope.cleanUnduplicated scope.mapRedundancyExceptAttr transformNodes,'transform'
	for redundantNode, transformAttrList of redundancyMap
		do (redundantNode, transformAttrList)->
			canonicalNode = scope.canonicalize redundantNode, fileContent
			id = scope.getAttrValue canonicalNode, 'id'
			fileContent = scope.append2Node 'defs', canonicalNode, fileContent
			for transformAttr in transformAttrList
				do (transformAttr)->
					refNode = scope.createTransformUseNode id, transformAttr
					duplicatedNode = scope.injectAttrContent(redundantNode, 'transform', transformAttr)
					fileContent = scope.replaceNode duplicatedNode, refNode, fileContent
	return fileContent

scope.Idrator = (init='9')->
	_charMap = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	@next = =>
		@_incrementLastIdSchema()
		@_idSchema2id _lastIdSchema
	@last = =>
		@_incrementLastIdSchema() if '9' == @_idSchema2id _lastIdSchema
		@_idSchema2id _lastIdSchema

	@_incrementIdSchema = (idSchema)=>
		updatedSchema = idSchema.slice()
		for curseur in [1.._charMap.length]
			updatedSchema[updatedSchema.length-curseur] = (updatedSchema[updatedSchema.length-curseur]+1) % _charMap.length
			if updatedSchema[updatedSchema.length-curseur]
				break
		if updatedSchema[0] == 0
			updatedSchema[0] = 10
			updatedSchema.push 0
		return updatedSchema

	@_id2idSchema = (id)=>
		idSchema = []
		id.split('').forEach (chr)->
			position = 	_charMap.search chr
			throw chr + ' incorrect chr as id part' if position == -1
			idSchema.push position
		return idSchema

	_lastIdSchema = @_id2idSchema init
	@_incrementLastIdSchema = ()=> _lastIdSchema = @_incrementIdSchema _lastIdSchema
	@_idSchema2id = (idSchema)=>
		id = ''
		idSchema.forEach (charPos)->
			id += _charMap.charAt charPos
		return id
	return @
scope.nextId = (id)->
	(new scope.Idrator id).next()
scope.isIdAvailable = (id, fileContent)->
	!RegExp(' id="'+id+'"').test fileContent
scope.nextAvailableId = (fileContent)->
	scope.nextAvailableId.idRator = new scope.Idrator() if !scope.nextAvailableId.idRator
	id = scope.nextAvailableId.idRator.last()
	return id if scope.isIdAvailable id, fileContent
	scope.nextAvailableId.idRator.next()
	return scope.nextAvailableId fileContent
scope.canonicalize = (string, fileContent)->
	id = scope.nextAvailableId fileContent
	return string.replace 'transform=""','id="'+id+'"'
scope.append2Node = (nodeName, string2append, fileContent)->
	return fileContent.replace '</'+nodeName+'>', string2append+'</'+nodeName+'>'
scope.createTransformUseNode = (id, transformContent)->
	return '<use xlink:href="#'+id+'" transform="'+transformContent+'"/>'
scope.replaceNode = (beforeNode, afterNode, fileContent)->
	return fileContent.split(beforeNode).join(afterNode)
