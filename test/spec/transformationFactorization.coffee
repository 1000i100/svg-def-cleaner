sdc = require '../../bin/svg-def-cleaner'
describe 'factorisation des transformations', ->
	it "liste les balises dotées d'un attribut transform (et le contenu de ces balises)", ->
		inputData = '<b transform="b">b</b><c>c</c><d transform="d"/>'
		expectedResult = ['<b transform="b">b</b>','<d transform="d"/>']
		output = sdc.listTransformNodes inputData
		output.should.deep.equal expectedResult
	it "extrait la valeur du premier attribut transform d'une chaîne", ->
		output = sdc.getTransformAttr '<b transform="first">b</b><d transform="second"></d>'
		output.should.deep.equal 'first'
###
	it "supprime la valeur de l'identifiant dans la chaîne", ->
		output = sdc.removeId '<b id="firstId">b</b>'
		output.should.deep.equal '<b id="">b</b>'
###