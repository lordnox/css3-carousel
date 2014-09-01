"use strict"

# var conf = require('./conf.'+process.env.NODE_ENV);
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)


# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->
  require("load-grunt-tasks") grunt
  require("time-grunt") grunt

  # configurable paths
  yeomanConfig =
    app: "src"
    dist: "dist"

  try
    yeomanConfig.app = require("./bower.json").appPath or yeomanConfig.app

  grunt.initConfig
    yeoman: yeomanConfig
    watch:
      files: ["<%= yeoman.app %>/**/*.coffee"]
      tasks: ["coffee:dist"]

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp", "<%= yeoman.dist %>/*", "!<%= yeoman.dist %>/.git*"]
        ]

      all:
        [".tmp", "node_modules"]

      server: ".tmp"

    coffee:

      dist:
        options:
          sourceMap: true
          sourceRoot: ""
        files: [
          expand: true
          cwd: "<%= yeoman.app %>"
          src: "**/*.coffee"
          dest: "<%= yeoman.dist %>"
          ext: ".js"
        ]



  grunt.registerTask "build", ["clean:dist", "coffee:dist"]

  grunt.registerTask "default", ["build"]