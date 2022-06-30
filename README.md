# moshy

![](http://imgur.com/OMLTr26.gif)  
created with moshy's pdupe options

**moshy** is a command line datamoshing utility kit for AVI files, based heavily on [aviglitch](https://github.com/ucnv/aviglitch).
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

## June 2022 Update - Moshy 2.0.0

With the release of Ruby 3, many dependencies for this project broke. I have updated this for the following versions, but I don't support this software actively anymore and haven't tested on various devices, platforms, etc., but if you have the right dependencies everything should work as normal:

- Ruby 3.1.2
- Bundler 2.3.7
- ffmpeg 5

If you already use moshy, run the following:

```
gem uninstall moshy
gem uninstall slop
gem install moshy -v 2.0.1
```

That should work. If not, please file an issue and I will try to get to it.

## Get it!

You'll need to install [Ruby](https://www.ruby-lang.org/en/). If you're on Mac OS X, you probably already have a local version of Ruby installed. Once that's done, you can use Rubygems (which comes with Ruby) to install moshy:

```
gem install moshy -v 2.0.1
```

From there, you can use `moshy` from the command line.

For a couple commands (`prep` and `bake`), you need to have ffmpeg installed locally.
[You can get it for your OS here.](https://www.ffmpeg.org/download.html)

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

## Quick tutorial

Here's a short example of how you might use moshy to create a P-dupe mosh:

1. Choose a YouTube video you want to mosh (I'll use "Charlie bit my finger": <https://www.youtube.com/watch?v=bnRVheEpJG4>)
2. Download it with KeepVid (<http://keepvid.com/?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DbnRVheEpJG4>)
3. "Prep" it with moshy to turn it into an .AVI with minimal I-Frames and all P-frames (because B-frames don't mosh well):  
   `moshy -m prep -i charlie.mp4 -o charlie.avi`
4. Open charlie.avi in avidemux and clip it down to the segment I want (moshy will soon be able to do this with a "clip" command): ![](http://i.imgur.com/OBy8pbB.png)
5. Open charlie_clip.avi and find the frame I want to P-dupe mosh (here, frame 196): ![](http://i.imgur.com/aZsZIx6.png)
6. Use moshy in pdupe mode to dupe frame 196 60 times:  
   `moshy -m pdupe -i charlie_clip.avi -f 196 -d 60 -o charlie_clip-dupe.avi`  
   Open it in a video player (I use VLC) and see if it looks good.
7. Awesome, I love it, but I want to clip it down to size. However, since it has so few I-frames, if I just clip it anywhere, the beginning of the video will become corrupted because of lack of pixel data. Let's use moshy to bake the mosh:  
   `moshy -m bake -i charlie_clip-dupe.avi -o charlie_clip-dupe-bake.avi`
8. Done. Let's open it back up in avidemux, clip it down to size, and save our final result: ![](http://i.imgur.com/07abIqT.png)
9. Looks good to me. Let's save it as an MP4 so that I can upload it to Giphy, which will convert it into a .gif for me. (I'm hoping to add modes to moshy that convert videos to .gif and .mp4 directly, too.)
10. Done! ![](https://media.giphy.com/media/3o85xoWYyG1HEVs8Vy/giphy.gif)

## Trouble?

Having issues? Please [file an issue](https://github.com/wayspurrchen/moshy/issues/new)!
