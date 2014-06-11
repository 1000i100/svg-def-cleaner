sdc = require '../../bin/svg-def-cleaner'
describe 'détection de redondance', ->
	it "extrait le contenu de la balise <defs>", ->
		output = sdc.getDefs 'before<defs>in<side/>\n</defs><after>content</after>'
		output.should.equal 'in<side/>\n'
	it "liste les balises sans enfant", ->
		output = sdc.listNodesWithoutChild '<a>b<a>a</a></a>b<a id="b"></a><a id="c"><a>ça</a></a>'
		output.should.deep.equal ['<a>a</a>','<a id="b"></a>','<a>ça</a>']
		# vérifie qu'il n'y a pas de surprise si un seul résultat est trouvé.
		output = sdc.listNodesWithoutChild '<a>b<a>a</a></a>'
		output.should.deep.equal ['<a>a</a>']
	it "retourne la première balise sans enfant", ->
		output = sdc.getFirstNodeWithoutChild '<a>b<a>a</a></a>b<a id="b"></a><a id="c"><a>ça</a></a>'
		output.should.equal '<a>a</a>'

	describe "liste les balises dotées d'un attribut id (et le contenu de ces balies)", ->
		it "quel que soit l'imbrication", ->
			inputData = '<a>a</a><b id="b">b</b><c>c</c><d id="d"><e>e</e></d><f><g>g</g></f><h><i id="i">i</i></h>'
			expectedResult = ['<b id="b">b</b>','<d id="d"><e>e</e></d>','<i id="i">i</i>']
			output = sdc.listIdNodes inputData
			output.should.deep.equal expectedResult
		it "sans s'emmêler dans les balises fermantes identiques", ->
			inputData = '<a>a</a><a id="b">a</a><a>a</a><a id="d"><a>a</a></a><a><a>a</a></a><a><a id="i">a</a></a>'
			expectedResult = ['<a id="b">a</a>','<a id="d"><a>a</a></a>','<a id="i">a</a>']
			output = sdc.listIdNodes inputData
			output.should.deep.equal expectedResult

	it "extrait la valeur du premier attribut id d'une chaîne", ->
		output = sdc.getId '<b id="firstId">b</b><d id="secondId"></d>'
		output.should.deep.equal 'firstId'
	it "supprime la valeur de l'identifiant dans la chaîne", ->
		output = sdc.removeId '<b id="firstId">b</b>'
		output.should.deep.equal '<b id="">b</b>'
	it "construit une map avec les chaîne sans id en clef et la liste des id en valeurs", ->
		inputData = ['<b id="b">b</b>','<b id="c">b</b>','<i id="i">i</i>']
		expectedResult = {'<b id="">b</b>':['b','c'],'<i id="">i</i>':['i']}
		output = sdc.mapRedudency inputData
		output.should.deep.equal expectedResult
	it "nettoie la map de redondance des données non redondantes", ->
		inputData = {'<b id="">b</b>':['b','c'],'<i id="">i</i>':['i']}
		expectedResult = {'<b id="">b</b>':['b','c']}
		output = sdc.cleanUnduplicated inputData
		output.should.deep.equal expectedResult
