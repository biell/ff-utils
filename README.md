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

*clips* has a slightly intuitive command-line interface which is much
simpler to understand and use than the `ffmpeg` interface.  While being
easier to use, this comes with the price of limited functionality and
limited configuration/predefined defaults.  For times when *clips* can
get you almost all the way to a perfect script, it can be used to provide
the `ffmpeg` command to run instead of actually running it.  This can
then be modified to produce the exact desired result.

The idea behind *clips* is to easily produce videos for upload to sites
like youtube or vimeo that rival the quality of most content with minimal
effort.

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
  cover the entire window, the video ends.

        clips carousel.mp4 src1.mp4 0-10 /10/L src2.mp4 0-10 /10/L     \
          src3.mp4 0-10 /10/L src4.mp4 0-10 /10/L src1.mp4 10-20 /10/L \
          src2.mp4 10-20 /10/L src3.mp4 0-20 /10/L src4.mp4 10-15 

