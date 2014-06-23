sdc = require '../../bin/svg-def-cleaner'
describe 'détection de redondance', ->
	it "extrait le contenu de la balise <defs>", ->
		output = sdc.getDefs 'before<defs>in<side/>\n</defs><after>content</after>'
		output.should.equal 'in<side/>\n'

	describe "liste les balises dotées d'un attribut spécifique (et le contenu de ces balies)", ->
		it "quel que soit l'imbrication", ->
			inputData = '<a>a</a><b id="b">b</b><c>c</c><d id="d"><e>e</e></d><f><g>g</g></f><h><i id="i">i</i></h>'
			expectedResult = ['<b id="b">b</b>','<d id="d"><e>e</e></d>','<i id="i">i</i>']
			output = sdc.listNodesWithAttr inputData, 'id'
			output.should.deep.equal expectedResult
		it "sans s'emmêler dans les balises fermantes identiques", ->
			inputData = '<a>a</a><a id="b">a</a><a>a</a><a id="d"><a>a</a></a><a><a>a</a></a><a><a id="i">a</a></a>'
			expectedResult = ['<a id="b">a</a>','<a id="d"><a>a</a></a>','<a id="i">a</a>']
			output = sdc.listNodesWithAttr inputData, 'id'
			output.should.deep.equal expectedResult

	it "extrait la valeur du premier attribut spécifique d'une chaîne", ->
		output = sdc.getAttrValue '<b id="first">b</b><d id="second"></d>', 'id'
		output.should.deep.equal 'first'
	it "supprime la valeur d'un attribut défini dans la chaîne fournie", ->
		output = sdc.removeAttrContent '<b id="first">b</b>', 'id'
		output.should.deep.equal '<b id="">b</b>'
	it "construit une map avec les chaîne sans id en clef et la liste des id en valeurs", ->
		inputData = ['<b id="b">b</b>','<b id="c">b</b>','<i id="i">i</i>']
		expectedResult = {'<b id="">b</b>':['b','c'],'<i id="">i</i>':['i']}
		output = sdc.mapRedundancyExceptAttr inputData, 'id'
		output.should.deep.equal expectedResult
	it "nettoie la map de redondance des données non redondantes", ->
		inputData = {'<b id="">b</b>':['b','c'],'<i id="">i</i>':['i']}
		expectedResult = {'<b id="">b</b>':['b','c']}
		output = sdc.cleanUnduplicated inputData
		output.should.deep.equal expectedResult
