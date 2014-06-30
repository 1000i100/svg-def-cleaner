sdc = require '../../bin/svg-def-cleaner'
describe 'factorisation des transformations', ->
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
#	it "construit une balise qui servira de références", ->
#		return
#	it "ajoute la balise de références aux defs", ->
#		return
#	it "construit une référence avec transformation", ->
#		return
#	it "ajoute la référence transformée à la place de la balise dupliquée", ->
#		return
