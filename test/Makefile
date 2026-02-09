#Test suite for clips

TESTS = concat-4k grid1 grid2 overlay-4k simple fade transition mirror tro \
		groovy passthrough tteffect1 tteffect2 carousel blur three text \
		clipings wind utran

all: font $(addsuffix .mp4, $(TESTS))
	@echo
	@echo TESTS COMPLETE
	@echo

font:
	@[ `clips -print=fonts -F 'sans bold italic' | wc -l` -gt 2 ]

concat-4k.mp4:
	clips $@ src/town-4k-10.mp4 0- \
		src/dam-4k-10.mp4 0- src/rocks-4k-10.mp4 0-

grid1.mp4: concat-4k.mp4
	clips -r:in 1920:1080 -0 concat-4k.mp4 -1 src/mountain-4k-30.mp4 \
		-2 src/adjust-4k-30.mp4 -3 src/pattern-4k-30.mp4 $@         \
		{/v {/h [0]0:05-0:25 [1]0:01-0:21 } {/h [2]0:09-0:29 [3]0:01-0:21 } }

grid2.mp4:
	clips $@ {/2x2 src/bear-hd-30.mp4 0-15 src/plasma-hd-30.mp4 0-15 \
		src/clock-hd-30.mp4 0-15 src/sunset-hd-30.mp4 0-15 }

overlay-4k.mp4: grid1.mp4
	clips -d $@ grid1.mp4 0- '%/div(W-w,2):div(H-h,2)' \
		src/melting-vert-ld-30.mp4 scale/810:1440 0:05-0:25

simple.mp4:
	clips $@ src/autumn-hd-10.mp4 0-0:05 0:07-0:09  src/river-hd-10.mp4 0- \
		src/swans-hd-10.mp4 0:01-0:03 0:05-0:07 0:09-

fade.mp4: simple.mp4
	clips $@ simple.mp4 fadein/2 flip 0:03.369-16.900 fadeout

transition.mp4:
	clips $@ src/mashup-hd-22.mp4 0-5.467 /1.8 16.700-

mirror.mp4:
	clips $@ src/owl-hd-30.mp4 0-0:10 /2.3/U flip/v 0:07.7-0:17

tro.mp4:
	clips -r 1920:1080 $@ src/rca-720-30.mp4 0:20-0:25 {/v \
			src/autumn-hd-10.mp4 crop/1920:540 0-        \
			src/swans-hd-10.mp4 crop/1920:540:0:540 0-   \
		} src/bars-hd-30.mp4 0-5

groovy.mp4:
	clips $@ src/autumn-hd-10.mp4 0- %/lime:0.12:0.2 src/plasma-hd-30.mp4 5-13

passthrough.mp4:
	clips $@ src/clock-hd-30.mp4 ffmpeg/v/unsharp=7:7:-2:7:7:-2 0-0:15

tteffect1.mp4:
	clips $@ src/walking-vert-hd-10.mp4 fade-in {/h     \
			crop/448:1080:1:280 flip ffmpeg/v/gblur=40 0-  \
			crop/1024:1080:0:280 0-                        \
			crop/448:1080:-1:280 flip ffmpeg/v/gblur=40 0- \
		} fade-out

tteffect2.mp4:
	clips $@ src/beach-vert-4k-10.mp4 fade-in { \
			scale/2560:1440/fill crop/2160:2000:0:1000 ffmpeg/v/gblur=50 0- \
			%/'(W-w)\/2':0 scale/1216:1440/fill crop/2160:2560:0:800 0-     \
		} fade-out

carousel.mp4:
	clips -r:in 1080:1920 -1 src/a-vert-hd-30.mp4 -2 src/b-vert-hd-30.mp4 \
		-3 src/cutting-vert-ld-30.mp4 -4 src/melting-vert-ld-30.mp4 $@   \
		[1] 5-10 /5/L  [2] 0-10 /5/L  [3] 0-10 /5/L  [4] 0-10 /5/L       \
		[1] 10-20 /5/L [2] 10-20 /5/L [3] 10-20 /5/L [4] 10-15 

blur.mp4:
	clips $@ src/sunset-hd-30.mp4 blur-in speed/2 10-30 blur-out

three.mp4:
	clips $@  -0 src/a-vert-hd-30.mp4 -1 src/explode-vert-hd-10.mp4    \
		-2 src/b-vert-hd-30.mp4 -3 src/bear-hd-30.mp4 scale/1920:1080 \
		{\a  {\h [0] v/0.3 10-20 [1] v/0.8 0-10 [2] v/0.5 5-15 }      \
		[3] audio v/2 0- }

text.mp4: three.mp4
	clips $@ three.mp4 -F 'roman italic' \
		text/blue@0.6/320pt/120:100+n/2-7/'Loren Ipsum' 0-

clipings.mp4:
	clips $@ src/mashup-hd-22.mp4 scale/1920:1080 {/h	\
			crop/536:930:225:70  4.083-7.550		\
			crop/536:930:792:70  4.083-7.550		\
			crop/536:930:1361:70 4.083-7.550		\
		}

wind.mp4:
	clips $@ src/autumn-hd-10.mp4 0- /3/hlwind src/clouds-hd-39.mp4 0-10

utran.mp4: tro.mp4
	clips -F ../userfilters.clips $@ tro.mp4 0-4 /lcut 8-14


clean:
	rm -f *.mp4

