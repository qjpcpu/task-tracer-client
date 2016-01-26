gulp = require 'gulp'
coffee = require 'gulp-coffee'

gulp.task 'default', ->
  gulp.src ['index.coffee']
    .pipe coffee()
    .pipe gulp.dest('./tmp')
   