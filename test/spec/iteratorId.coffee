sdc = require '../../bin/svg-def-cleaner'
describe "Idrator", ->
	describe "itère sur tout les id éligibles (norme xml W3C)", ->
		it "en commençant par les plus courts.", ->
			idrator = new sdc.Idrator
			idrator.next().should.equal 'a'
			idrator.next().should.equal 'b'
		it "en continuant là ou on lui demande", ->
			idrator = new sdc.Idrator 'Z'
			idrator.next().should.equal 'a0'
			idrator.next().should.equal 'a1'
		it "usage statique", ->
			sdc.nextId('z').should.equal 'A'
			sdc.nextId('a9').should.equal 'aa'
	describe "conversion interne", ->
		it "id vers idSchema 1 caractère", ->
			idrator = new sdc.Idrator
			idrator._id2idSchema('a').should.deep.equal [10]
		it "id vers idSchema plus d'1 caractère", ->
			idrator = new sdc.Idrator
			idrator._id2idSchema('a1').should.deep.equal [10,1]
		it "idSchema vers id 1 caractère", ->
			idrator = new sdc.Idrator
			idrator._idSchema2id([10]).should.equal 'a'
		it "idSchema vers id plus d'1 caractère", ->
			idrator = new sdc.Idrator
			idrator._idSchema2id([10,1]).should.equal 'a1'
		it "id vers idSchema vers id retourne le même id que d'origine", ->
			idrator = new sdc.Idrator
			idTest = 'a0Z'
			doubleConversion = idrator._idSchema2id(idrator._id2idSchema(idTest))
			doubleConversion.should.equal idTest
