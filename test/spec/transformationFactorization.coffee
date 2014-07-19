sdc = require '../../bin/svg-def-cleaner'
describe 'factorisation des transformations', ->
	beforeEach ->
		sdc.nextAvailableId.idRator = false
	it "liste les balises dotées d'un attribut transform (et le contenu de ces balises)", ->
		inputData = '<b transform="b">b</b><c>c</c><d transform="d"/>'
		expectedResult = ['<b transform="b">b</b>','<d transform="d"/>']
		output = sdc.listNodesWithAttr inputData, 'transform'
		output.should.deep.equal expectedResult
	it "extrait la valeur du premier attribut transform d'une chaîne", ->
		output = sdc.getAttrValue '<b transform="first">b</b><d transform="second"></d>', 'transform'
		output.should.deep.equal 'first'
	it "supprime le contenu de l'attribut transform dans la chaîne", ->
		output = sdc.removeAttrContent '<b transform="first">b</b>', 'transform'
		output.should.deep.equal '<b transform="">b</b>'
	it "test la disponibilité d'un id", ->
		sdc.isIdAvailable('a','<b id="a">b</b>').should.equal false
		sdc.isIdAvailable('a','<b id="b">b</b>').should.equal true
	it "retourne le prochain id disponible", ->
		sdc.nextAvailableId('<b id="a">b</b>').should.equal 'b'
	it "construit une balise qui servira de références", ->
		output = sdc.canonicalize '<b transform="">b</b>', '<b transform="sdf">b</b><a id="a"/>'
		output.should.equal '<b id="b">b</b>'
	it "ajoute la balise de références aux defs", ->
		output = sdc.append2Node 'defs', '<any>thing</any>', '<defs></defs>'
		output.should.equal '<defs><any>thing</any></defs>'
	it "construit une référence avec transformation", ->
		output = sdc.createTransformUseNode 'a', 'anything'
		output.should.equal '<use xlink:href="#a" transform="anything"/>'
	it "remplace la balise dupliquée par la référence transformée", ->
		output = sdc.replaceNode '<a>plop</a>', '<b/>', '<a>plop</a><b><a>plop</a></b><a>plop</a>'
		output.should.equal '<b/><b><b/></b><b/>'
