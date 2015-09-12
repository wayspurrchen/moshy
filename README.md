# moshy

moshy is a command line datamoshing utility kit for AVI files, based heavily on [aviglitch](https://github.com/ucnv/aviglitch).
It's designed to make common datamoshing tasks easier without having to open avidemux or other GUI tools. It lets you do stuff like:

- Convert video files into AVI video files with minimal I-Frames and no B-frames for ultimate moshability
- Create P-Frame duplication effects quickly
- Split a long video file into multiple clips based on its I-Frames
- "Bake" your datamoshed video, encoding the corruption as actual video content for uploading to video services or moshing even further!
- Identifying keyframe and deltaframe indexes in any AVI file
- ...and more!

If you don't know how to use the command line, this is a great opportunity to learn:

- Mac OS X Tutorial: http://blog.teamtreehouse.com/introduction-to-the-mac-os-x-command-line
- Windows Tutorial: http://lifehacker.com/5633909/who-needs-a-mouse-learn-to-use-the-command-line-for-almost-anything

## Get it!

You'll need to install [Ruby](https://www.ruby-lang.org/en/). If you're on Mac OS X, you probably already have a local version of Ruby installed. Once that's done, you can use Rubygems (which comes with Ruby) to install moshy:

```
gem install moshy
```

From there, you can use `moshy` from the command line.

## What's it do?

Moshy currently has six different modes:

- `prep` - Preps a video file for datamoshing with moshy by converting it
  into an AVI with no B-Frames (they're not good for moshing), and placing as
  few I-Frames as possible. Requires ffmpeg be installed locally.
- `isplit` - Extracts individual clips from an AVI where each clip is
  separated by I-frames in the original AVI. Great for getting specific
  clips out of a larger video and later doing I-frame moshing.
- `inspect` - Reads an .avi file and prints which video frames are keyframes
  (I-Frames) and which frames are delta frames (P-frames or B-frames). moshy
  cannot tell the difference between a P-frame or a B-frame, so you will want
  to use avidemux or another program if you need to know.
- `pdupe` - Duplicates a P-frame at a given frame a certain amount. To find
  out which frames are P-frames, use software like avidemux to look at the
  frame type. WARNING: This mode is a little glitchy. You may need to set
  the interval 1 or 2 above or below the frame number you actually want to
  duplicate. I'm not sure why this happens, but try it with a small
  duplication amount first. NOTE: This can mode take a while to process
  over 60-90 frame dupes.
- `ppulse` - Takes c number of frames and every n frames and duplicates them a
  given amount, resulting in a consistent P-duplication datamosh that's
  good for creating rhythmic effects. This was originally created to
  create mosh effects in sync with a beat for a music video.
- `bake` - "Bakes" your datamosh by creating a new video file from your
  datamoshed .avi, causing the datamosh effects to be treated as the actual
  content of the new video instead of an error. Requires ffmpeg to be
  installed locally.

You can access detailed info on how to use each of them from the command line with
the command `moshy -m <mode> --help`.

## Cool!

If you think this is cool, you'll probably find my list of [glitch art resources](http://www.glitchet.com/resources)
useful as well as the [Glitchet newsletter](http://www.glitchet.com/), a free weekly futuristic
news and glitch aesthetic e-zine.