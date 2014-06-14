sdc = require '../../bin/svg-def-cleaner'
describe 'suppression des redondances', ->
	it "injecte un id dans un chain dont la valeur de l'attribut id à été supprimé", ->
		output = sdc.injectId 'b', '<b id="">b</b>'
		output.should.deep.equal '<b id="b">b</b>'
	it "supprime la définition dupliquée", ->
		redundantString = '<b id="c">b</b>'
		fileContent = '<b id="b">b</b><b id="c">b</b>'
		expectedResult = '<b id="b">b</b>'
		output = sdc.removeDuplicateDef redundantString, fileContent
		output.should.deep.equal expectedResult