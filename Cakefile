# Utilities
fs = require 'fs'
exec  = (require 'child_process').exec

# CoffeeKup templating
coffeekup = require 'coffeekup'

# Using the power of `find` we do a quick recursive search for CoffeeCcript files
findAppCoffeeScripts = (callback) ->
    exec 'find browser/app -name \\*.coffee', (err, stdOut, stdIn) ->
        files = stdOut.split '\n'
        callback files

# Quick 'n dirty compile of the application logic
compileApp = () ->
    
    # Coffeescript compile command, will create a "concatenation.js"
    cmd = 'coffee -o static/js -j -c `find browser/app -name \\*.coffee`'
    
    exec cmd, (err, stdOut, stdIn) ->
        console.log err if err
        if not err?
            # Move the temp "concatenation.js" file to outputFile
            exec 'mv static/js/concatenation.js static/js/app.js', (err, stdOut, stdIn) ->
                console.log ('Error compiling browser app: '  + err) if err?
                console.log 'Compiled browser app' if not err?

# Compile the templates
compileTemplates = () ->
    fs.readFile 'browser/templates/templates.coffee', 'utf-8', (err, data) ->
        return if err?
        
        # Compiled string
        compiled = coffeekup.compile data
        
        # CoffeeKup returns anonymous fn, replace with "template"
        str = String(compiled).replace 'function anonymous', 'function template'
        
        # Write the templates into a single dir
        fs.writeFile 'static/js/templates.js', str, (err) ->
            console.log 'Error compiling templates' if err?
            console.log 'Compiled templates' if not err?

# Compile the entire browser environemtn
compile = () ->
    do compileApp
    do compileTemplates
    
# Single compile of everything
task 'compile', ->
    do compile

# Compress the js
task 'compress', ->
    
    # JS to compress
    files = ['static/js/app.js','static/js/templates.js']
    
    # Compress them
    for file in files 
        do (file) ->
            cmd = 'uglifyjs --overwrite ' + file
            exec cmd, (err, stdOut, stdIn) ->
                console.log ('Compressed ' + file) if not err?

# Watch files in this dir and compile on modify
task 'watch', ->

    # Initial compile (we always do one)
    do compile
    
    # Check a file's mtime and recompile if it's bigger than lastMTime
    checkFile = (file, lastMTime, fn) ->
        fs.stat file, (err, stat) ->
            return if not stat?
    
            compDate = new Date stat.mtime
            if compDate > lastMTime
                lastMTime.setTime do compDate.getTime
                do fn

    # Highest last modification ime of application files
    appLastMTime = new Date
    
    # Same for the templates
    templatesLastMTime = new Date
    
    # Watch the files with an interval
    interval = () ->
    
        # Watch app
        findAppCoffeeScripts (files) ->
            for file in files
                do (file) ->
                    checkFile file, appLastMTime, () ->
                        do compileApp
        
        # Watch templates
            checkFile 'templates/templates.coffee', templatesLastMTime, () ->
                do compileTemplates
                
    setInterval interval, 250