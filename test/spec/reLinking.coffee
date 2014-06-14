sdc = require '../../bin/svg-def-cleaner'
describe 'Correction des liens', ->
	it "corrige les liens vers des définitions redondantes", ->
		canonicalId = 'b'
		redundantId = 'ccc'
		fileContent = '<osef xlink:href="#b"/><osef xlink:href="#ccc" style="background:url(#ccc) #ccc" filter="url(#ccc)"/>'
		expectedResult = '<osef xlink:href="#b"/><osef xlink:href="#b" style="background:url(#b) #ccc" filter="url(#b)"/>'
		output = sdc.fixLink canonicalId, redundantId, fileContent
		output.should.deep.equal expectedResult