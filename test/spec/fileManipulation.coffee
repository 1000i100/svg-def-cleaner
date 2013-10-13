describe 'manipulation de fichier', ->
	it "lit le contenu brut d'un fichier", ->
		fileContent = loadFile "../demoFiles/dummy.txt"
		fileContent.should.equal 'hello world'