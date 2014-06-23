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
