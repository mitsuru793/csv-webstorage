gulp = require 'gulp'
loadPlugins = require 'gulp-load-plugins'
$ = loadPlugins()

srcPath     = './src'
destPath    = './dest'

gulp.task 'coffee:compile', ->
  gulp.src srcPath + '/**/*.coffee'
    .pipe $.plumber()
    .pipe $.coffee()
    .pipe $.uglify()
    .pipe $.rename extname: '.js'
    .pipe gulp.dest destPath

gulp.task 'default', ->
  gulp.watch [srcPath + '/**/*.coffee'], ['coffee:compile']
