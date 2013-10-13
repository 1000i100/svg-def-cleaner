fs              = require 'fs'
ps              = require 'path'
{exec,spawn}    = require 'child_process'
util            = require 'util'
watch           = require 'watch'
glob            = require 'glob'
Q               = require 'q'
coffee          = require 'coffee-script'
mkdirp          = require 'mkdirp'
Mocha           = require 'mocha'
rimraf          = require 'rimraf'
require 'colors'

#config
fichierATester = 'svg-def-cleaner'

appSourceDir    = 'src/'
appCompiledDir  = 'bin/'
specDir         = 'test/spec/'
specCompiledDir = 'bin/test/'
testConfigFile  = './test/config.coffee'
oneShotReporter = 'nyan' #"progress"
watchReporter   = 'min' #"dot"
runTestDelay    = 500 # latence entre la détection d'un fichier modifié et l'execution des test (pour éviter les test en cascade lors des enregistrement de masse)

# internal globals
untestedChange = false
verbose = false
debug = false

option '-v', '--verbose', 'affichage détaillé'
option '-V', '--veryverbose', 'affichage très détaillé (debug)'

task 'dummy', 'sandbox task for building process experiment'.cyan, (options)->
    setGlobalOptions options
    console.log 'dummy is dummy'.rainbow.bold

task 'watch', "A chaque changement sauvegardé, recompile les fichiers concernés et exécute les tests".cyan, (options)->
    watchTask options

watchTask = (options)->
    setGlobalOptions options
    Q(buildTask options).then ->
        testTask options
        new Monitor(appSourceDir,appFileChange,appFileChange,rmAppFile)
        new Monitor(specDir,specFileChange,specFileChange,rmSpecFile)


task "test", "exécute les tests".cyan, (options)->
    testTask options

testTask = (options, reporter=oneShotReporter)->
    q = Q.defer()
    setGlobalOptions options
    util.log 'Préparation des tests'.cyan if debug
    require testConfigFile

    # TODO: arboressance applicative à inclure pour lancer les test dessus.
    delete require.cache[ps.resolve('.', appCompiledDir+fichierATester+'.js')] # chemin absolue nécessaire
    require './'+appCompiledDir+fichierATester+'.js'

    mocha = new Mocha
    mocha.reporter reporter
    testFilesPattern = specCompiledDir+'**/*.js'
    util.log 'Liste les fichiers répondant au motif '.cyan + testFilesPattern if debug
    glob testFilesPattern, (err, fileList)->
        for file in fileList
            util.log 'spec : '.cyan + file if debug
            delete require.cache[ps.resolve('.', file)] # chemin absolue nécessaire
            mocha.addFile file
        util.log 'Execution des tests'.cyan if verbose
        runner = mocha.run ->
            util.log 'Tests terminés'.cyan if verbose
            q.resolve()
    q.promise


task 'build', 'compile tous les fichiers des dossiers '.cyan + appSourceDir + ' dans '.cyan + appCompiledDir + ' et '.cyan + specDir + ' dans '.cyan + specCompiledDir, (options)->
    buildTask options

buildTask = (options)->
    q = Q.defer()
    setGlobalOptions options
    Q.all([
        coffee2jsTree specDir, specCompiledDir
        coffee2jsTree appSourceDir, appCompiledDir
    ]).done ->
        util.log 'Compilation terminée'.cyan
        q.resolve()
    q.promise

task "clean", "supprime les dossiers ".cyan + specDir + ' et '.cyan + appSourceDir, (options)->
    cleanTask options

cleanTask = (options)->
    setGlobalOptions options
    util.log "Nétoyage du projet...".cyan
    Q.all([
        rmRecursive specCompiledDir
        rmRecursive appCompiledDir
    ]).done ->
        util.log "Nétoyage Terminé".cyan




appFileChange = (file) ->
    # recompiler puis lancer les test
    coffee2js(file, coffee2jsChPathName file, appSourceDir, appCompiledDir).then ->
        untestedChange = true
        setTimeout runTestIfChange, runTestDelay

specFileChange = (file) ->
    # recompiler puis lancer les test
    coffee2js(file, coffee2jsChPathName(file, specDir, specCompiledDir)).then ->
        untestedChange = true
        setTimeout runTestIfChange, runTestDelay

rmSpecFile = (file) ->
    # supprimer la version compiler puis lancer les test
    rmRecursive(coffee2jsChPathName file, specDir, specCompiledDir).then ->
        untestedChange = true
        setTimeout runTestIfChange, runTestDelay

rmAppFile = (file) ->
    # supprimer la version compiler puis lancer les test
    rmRecursive(coffee2jsChPathName file, appSourceDir, appCompiledDir).then ->
        untestedChange = true
        setTimeout runTestIfChange, runTestDelay

coffee2js = (coffeeFile, jsFile) ->
    # si le js n'existe pas ou est plus vieux, compiler, sinon, ne rien faire.
    q = Q.defer()
    
    Q.allSettled([
        fs_stat coffeeFile
        fs_stat jsFile
    ]).then (res)->
        if res[0].state is "fulfilled"
            coffeeTime = res[0].value.mtime
        else
            q.reject res[0].reason
        if res[1].state is "fulfilled"
            jsTime = res[1].value.mtime
        if !jsTime or jsTime < coffeeTime
            util.log 'Compile '.yellow + coffeeFile + ' to '.yellow + jsFile if verbose
            # open file
            fs.readFile coffeeFile, 'utf8', (err, data) ->
                q.reject err if err
                # compile file
                compiled = coffee.compile data
                # extract path from path+filename
                path = jsFile.split('/')
                path.pop()
                path = path.join('/')
                # create dir if not exist
                mkdirp path, (err)->
                    q.reject err if err
                    # write file
                    fs.writeFile jsFile, compiled, (err) ->
                        q.reject err if err
                        q.resolve()
        else
            util.log jsFile + ' déjà à jour'.grey if debug
            q.resolve()
    q.promise

coffee2jsTree = (coffeeFolder, jsFolder) ->
    q = Q.defer()
    pattern = coffeeFolder+'**/*.coffee'
    util.log 'liste les fichiers répondant au motif '.cyan + pattern if debug
    glob pattern, (err, fileList)->
        q.reject err if err
        promesse = []
        for file in fileList
            promesse.push coffee2js file, coffee2jsChPathName file, coffeeFolder, jsFolder
        Q.all(promesse).then ->
                q.resolve coffeeFolder + ' -> ' + jsFolder + ' OK'
    q.promise

coffee2jsChPathName = (file, coffeeFolder, jsFolder)->
    file.replace(/\\/g,'/').replace(coffeeFolder, jsFolder).replace '.coffee', '.js'
    # correction de la coloration syntaxique de sublime text 2 ' 

Monitor = (folder, changeCallBack, newCallBack, rmCallBack) ->
    this.lastStamp = 'static var'
    this.lastFileList = []
    watch.watchTree folder, (file, curr, prev) ->
        this.lastFileList = [] if this.lastStamp isnt (new Date).toLocaleTimeString()
        this.lastStamp = (new Date).toLocaleTimeString()
        if prev is null and curr is null and file instanceof Object
            util.log "Finished walking ".cyan + folder + " tree".cyan if debug
        else
            if lastFileList[file]
                util.log ('echo '+file).grey if debug
            else
                if prev is null
                    util.log 'new '.green + file if verbose
                    newCallBack(file)
                else if curr.nlink is 0
                    util.log 'rm '.red + file if verbose
                    rmCallBack(file)
                else
                    util.log 'change '.yellow + file if verbose
                    changeCallBack(file)
            this.lastFileList[file]=true

setGlobalOptions = (options) ->
    if options
        if options.verbose then verbose = true
        if options.veryverbose
            verbose = true
            debug = true

delay = (ms, func) -> setTimeout func, ms

fs_stat = (file)->
    q = Q.defer()
    fs.stat file, (err, stat)->
        q.reject err if err
        q.resolve stat
    q.promise

rmRecursive = (folder)->
    q = Q.defer()
    rimraf folder, (err)->
        if err
            q.reject err
        else
            util.log folder + ' supprimé'.yellow if verbose
            q.resolve()
    q.promise

runTestIfChange = ->
    if untestedChange
        untestedChange = false
        testTask null, watchReporter
