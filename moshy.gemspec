Gem::Specification.new do |s|
  s.name        = 'moshy'
  s.version     = '0.1.0'
  s.date        = '2010-09-12'
  s.summary     = "datamoshing utility kit for common tasks with AVI files"
  s.description =
"moshy is a datamoshing utility kit for AVI files, based heavily on [aviglitch](https://github.com/ucnv/aviglitch).
It's designed to make common datamoshing tasks easier from a command line interface
without having to open avidemux or other GUI tools. It lets you do stuff like:

- Convert video files into AVI video files with minimal I-Frames and no B-frames for ultimate moshability
- Create P-Frame duplication effects quickly
- Split a long video file into multiple clips based on its I-Frames
- \"Bake\" your datamoshed video, encoding the corruption as actual video content for uploading to video services or moshing even further!
- Identifying keyframe and deltaframe indexes in any AVI file
- ...and more!

See https://github.com/wayspurrchen/moshy for detailed documentation."
  s.authors     = ["Way Spurr-Chen"]
  s.email       = 'wayspurrchen@gmail.com'
  s.files       = ["moshy.rb"]
  s.homepage    =
    'https://github.com/wayspurrchen/moshy'
  s.license       = 'MIT'
end