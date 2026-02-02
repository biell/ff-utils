ff-utils
========

Wrappers and utiltites to compliment/simplify [ffmpeg](https://ffmpeg.org/).
The main purpose of this repository is to serve the `clip` program which
provides a simpler interface for many video compositions.  The repository
also contains a module for shared code, and a small number of auxillary
utilitites.


FFUtils.pm
----------

This is a perl module which invokes `ffmpeg` and `ffprobe`, creating a
functional interface to these tools.  Additionally, it provides a a wrapper
function to `ffmpeg` to provide a simple to understand status meter and
ETA calculation.

clips
-----

**clips** has a slightly intuitive command-line interface which is much
simpler to understand and use than the `ffmpeg` interface.  While being
easier to use, this comes with the price of limited functionality and
limited configuration/predefined defaults.  For times when **clips** can
get you almost all the way to a perfect script, it can be used to provide
the `ffmpeg` command to run instead of actually running it.  This can
then be modified to produce the exact desired result.

The idea behind **clips** is to easily produce videos for upload to sites
like youtube or vimeo that rival the quality of most content with minimal
effort.

### Syntax

The command line for **clips** starts with options to affect the runtime
(see `clips -h` for a list) and then the output file name.  After that,
there are a series of tokens which affect the resulting video file.
Those tokens may be input file names, segements of video/audio (aka clips)
and a series of instructions which result in the generation of a
`ffmpeg -filter_complex` argument.  While the command-line can get long,
it should be vastly simpler than the corresponding `ffmpeg` command.

Take, as an example 4 people who participated in an Enduro race, each with
a helmet cam.  They all started recording at different times before the
start, so first we use a program (e.g. `mpv -osd-fractions`) to identify
the exact time they each crosses the start line, then we start the videos
exactly 5 seconds before that time.  We have 3 of the videos in standard
HD (1080p) and one in 2K video (1440p).  So, we scale the 2K video down
to standard high definition, and stack them two across on top with two
across on bottom; without chaning the resolutions further, we end up with
a 4K video.  Some of the recordings have different volumes, so we adjust
those, and add a little extra to the winning rider, so they stand out.
At 5 seconds in, we place the text "START" in red in the middle:center
(default location) of the screen where all the 4 videos intersect.  Then,
we print at the middle:top of each video the word "FINISH" in the default
black text a the moment they cross the finish line and keep it dislayed
for about 3 seconds.  Stitching this all together allows us to watch all
4 videos and compare how each rider is doing vís-a-ví each other.  The
resulting video is about 8 minutes, 30 seconds long.

        $ clips race.mp4 text/0:05-0:08/red/START                            \
          {/v                                                                \
            {/h jeff.mp4 text/8:03.349-8:06/middle:top/FINISH 0:14.367-8:44  \
                bodhi.mp4 text/7:58.903-8:02/middle:top/FINISH               \
                scale/1920:1080 v/0.7 1:03.130-9:33 }                        \
            {/h austen.mp4 text/7:46.201-7:50/middle:top/FINISH v/1.5        \
                0:37.284-9:07 nico.mp4 text/7:49.489-7:53/middle:top/FINISH  \
                v/0.5 0:21.697-8:51 }                                        \
          }

It produces the following `ffmpeg` command:

        ffmpeg -y -ac 2 -stats_period 6 -ss 14.367 -to 524 -i jeff.mp4
         -ss 63.13 -to 573 -i bodhi.mp4 -ss 37.284 -to 547 -i austen.mp4
         -ss 21.697 -to 531 -i nico.mp4 -filter_complex
         "[0:v]drawtext=x='(w-text_w)/2':y='h*0.01':fontcolor='black@0.9':enable='between(t,483.349,486)':fontsize='h/8':text='FINISH'[v3.1];
          [1:v]drawtext=fontcolor='black@0.9':enable='between(t,478.903,482)':y='h*0.01':x='(w-text_w)/2':fontsize='h/8':text='FINISH',scale=0:1080:force_original_aspect_ratio=decrease[v4.1];
          [1:a]volume=0.7[a4.1];[v3.1][v4.1]hstack=inputs=2:shortest=1[v2.2];[0:a][a4.1]amix=inputs=2:duration=shortest[a2.2];
          [2:v]drawtext=fontcolor='black@0.9':enable='between(t,466.201,470)':x='(w-text_w)/2':y='h*0.01':fontsize='h/8':text='FINISH'[v6.1];
          [2:a]volume=1.5[a6.1];[3:v]drawtext=fontsize='h/8':fontcolor='black@0.9':enable='between(t,469.489,473)':x='(w-text_w)/2':y='h*0.01':text='FINISH'[v7.1];
          [3:a]volume=0.5[a7.1];[v6.1][v7.1]hstack=inputs=2:shortest=1[v5.2];[a6.1][a7.1]amix=inputs=2:duration=shortest[a5.2];
          [v2.2][v5.2]vstack=inputs=2:shortest=1[v1.2];[a2.2][a5.2]amix=inputs=2:duration=shortest[a1.2];
          [v1.2]drawtext=x='(w-text_w)/2':y='(h-text_h)/2':fontcolor='red':enable='between(t,5,8)':fontsize='h/8':text='START'[v1.1]
         " -map "[v1.1]" -map "[a1.2]" race.mp4

And, the screen output looks like:

        Preprocessing (0:10.0)

                  Encoded/Target    Pct     Size    Elapsed/Expected
        Complete:  8:29.3/8:29.3 ,  99%, 1029 MB,   9.2 min/9.2   min  

        Output file:
        'race.mp4' (8:29.3)

Hopefully, this example illustrates how **clips** can simplify video
creation on the command-line without expensive video editing software.
And, your high-end software might be using `ffmpeg` under the covers
anyway.

Examples
--------

* Create `new.mp4` from 2 clips of `src1.mp4` followed by the entirety of
  `src2.mp4`

        clips new.mp4 src1.mp4 0:00.0-3:20.2 4:01.0-5:50.3 src2.mp4 0:00-

* Make `output.mp4` from a 1 minute and 26 second clip of `video.mp4` with
  the a `fade-in` of 2 seconds and the default fadeout of 3 seconds.

        clips output.mp4 video.mp4 fadein/2 0:20.369-1:46.900 fadeout

* Create `out.mp4` from 2 sections of `in.mp4` with the default transition
  type of `fade` and default time of 0.8 seconds.

        clips out.mp4 in.mp4 0:00-39.060 / 1:22.800-2:03.240

* Create `new.mp4` from all of `vid1.mp4` and `vid2.mp4` with a swipe up
  style transition of 1.4 seconds.

        clips new.mp4 vid1.mp4 0- /1.4/U vid2.mp4 0-

* Create a file `new.mp4` with 3 clips from `source.mp4` all using a
  2 second fade transition.
  
        clips new.mp4 source.mp4 0:13-0:44 /2 1:14-2:33 /2 4:11-5:01

* Create `new.mp4` by using an intro file, then having a segment consisting
  of the two files `left.mp4` and `right.mp4` stacked horizontally.  Finish
  off with two clips from the file `outro.mp4`.

        clips -g 1920:1080 new.mp4 intro.mp4 0-  \
          { left.mp4 0:19.600- right.mp4 0- }    \
          outro.mp4 0-0:34.369 /0.5 0:38.900-

* This will create a 30 second clip of top.mp4 layed over base.mp4 in a way
  that it is completely transparent for lime and very nearly lime colors,
  and slightly transparent for the rest of he colors.
  
        clips new.mp4 base.mp4 0-0:30 %70/lime:0.02:0.03 top.mp4 0-0:30

* Write `new.mp4` from the 10 seconds until 3 minutes, 45 seconds
  portion of `file.mp4`.  Use the *ffmpeg-filters(1)* filter `unsharp`
  as a simple video filtergraph.  `unsharp` is not defined inside of
  **clips**, but this filter will be passed through to *ffmpeg(1)* exactly
  as defined here.

        clips new.mp4 file.mp4 ffmpeg/v/unsharp=7:7:-2:7:7:-2 0:10-3:45

* Take a 1080x1920 vertical phone image, crop out the 1080x1080 section to
  keep, and suround it by blurred mirrors of the video content.  For extra
  fun, we could have added an `ffmpeg/v/eq=brightness=-0.4` to darken the
  blurred sides.
  
        clips wide.mp4 phone.mp4 fade-in {/h                             \
          crop/420:1080:1:-200 flip ffmpeg/v/gblur=40 0:12.727-2:04.265  \
          crop/1080:1080:0:-200 0:12.727-2:04.265                        \
          crop/420:1080:-1:-200 flip ffmpeg/v/gblur=40 0:12.727-2:04.265 \
        } fade-out


* Create a continuously scrolling video of 10 second clips from 4 different
  input files moving from right to left.  After the last video scrolls to
  cover the entire window, the video ends.  Use command-line placeholders
  for the video files.

        clips -1 src1.mp4 -2 src2.mp4 -3 src3.mp4 -4 src4.mp4 carousel.mp4 \
          [1] 0-10 /10/L  [2] 0-10 /10/L  [3] 0-10 /10/L [4] 0-10 /10/L \
          [1] 10-20 /10/L [2] 10-20 /10/L [3] 0-20 /10/L [4] 10-15 

* Print out all Sans fonts with a Bold and Italic style

        clips -print=fonts -F 'sans bold italic'


