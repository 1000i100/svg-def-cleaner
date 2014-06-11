sdc = require '../../bin/svg-def-cleaner'
describe 'manipulation de fichier', ->
	it "lit le contenu brut d'un fichier", ->
		fileContent = sdc.loadFile "test/demoFiles/dummy.txt"
		fileContent.should.equal 'hello world'
	it "écrit le contenu multi ligne brut d'un fichier", ->
		fileName = 'test/demoFiles/writeTest.txt'
		fileContent = "some multi\nline content\n"+Math.random()
		sdc.writeFile fileName, fileContent
		verificationContent = sdc.loadFile fileName
		verificationContent.should.equal fileContent
