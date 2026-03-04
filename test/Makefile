#Test suite for clips

TESTS = concat-4k concat-noaudio concat-withaudio fade grid1 grid2 overlay-4k \
		simple flip transition mirror tro groovy passthrough tteffect1 \
		tteffect2 carousel blur three text clipings wind utran \
		hash-a2ec2c90 box


CLIPS=clips $@ $(if $(TEXT),-description='$@: $(TEXT)',-description='$@')
FF=ffmpeg -loglevel error -y -map '[v]' -map '[a]' -to 30 $@ -filter_complex
VSRC=movie=src/
ASRC=amovie=src/
TIMER=drawtext=box=1:boxcolor=white@0.7:fontcolor=black:fontsize=24:x=32:y=32:boxborderw=16:text=%{pts\\:hms}

#######################
#RESOLUTIONS
#######################
SD=1080x720
TT=608x1080
HD=1920x1080
HDV=1080x1920
2K=2560x1440
2KV=1440x2560
4K=3840x2160
4KV=2160x3840

#######################
#DRIVERS
#######################
all: font novideo.mp3 $(addsuffix .mp4, $(TESTS))
	@echo
	@echo TESTS COMPLETE
	@echo

clean:
	rm -f novideo.mp3 $(addsuffix .mp4, $(TESTS))

clean-all:
	rm -f *.mp3 *.mp4

check:
	mpv --osd-align-x=center --osd-align-y=bottom --osd-duration=3000 \
		--osd-font-size=14 --osd-border-style=background-box \
		--osd-outline-size=1 --osd-color='#000000' \
		--osd-outline-color='#22FFFFFF' --osd-selected-color='#770000' \
		--osd-selected-outline-color='#FFFFFF' \
		--osd-back-color='#99FFFFFF' --osd-msg1='$${metadata/description}' \
		$(addsuffix .mp4, $(TESTS))

#######################
#SOURCES
#######################
mptest.mp4:
	$(FF) 'mptestsrc,scale=$(HD):reset_sar=1[v];sine=220:4[a]'

mandelbrot-4k.mp4:
	$(FF) 'mandelbrot=s=$(4K),$(TIMER)[v];$(ASRC)rock1.mp3[a]'

mandelbrot.mp4: mandelbrot-4k.mp4
	$(FF) 'movie=mandelbrot-4k.mp4,crop=1920:1080:240:10,$(TIMER)[v];$(ASRC)rock1.mp3[a]'

testsrc-4k.mp4:
	$(FF) 'testsrc=s=$(4K),$(TIMER)[v];anoisesrc=c=violet,volume=1+2*sin(t):eval=frame,aecho=1:0.7:1200:0.6[a]'

testsrc.mp4:
	$(FF) 'testsrc=s=$(HD),$(TIMER)[v];anoisesrc=c=violet,volume=1+2*sin(t):eval=frame,aecho=1:0.7:1200:0.6[a]'

testsrc2-2k.mp4:
	$(FF) 'testsrc2=s=$(2K),$(TIMER)[v];aevalsrc=sin(2600*t)[a]'

testsrc2.mp4:
	$(FF) 'testsrc2=s=$(HD),$(TIMER)[v];aevalsrc=sin(2600*t)[a]'

life.mp4:
	$(FF) 'life=s=$(HD):mold=1:life_color=green:death_color=yellow:mold_color=red,$(TIMER)[v];anoisesrc=c=pink,volume=0.05[a]'

life-vert.mp4:
	$(FF) 'life=s=$(HDV):mold=1:life_color=blue:death_color=yellow:mold_color=black,$(TIMER)[v];anoisesrc=c=white,volume=0.05[a]'

smptebars.mp4:
	$(FF) 'smptebars=s=$(HD),$(TIMER):fontsize=128:x=n:y=n[v];$(ASRC)yarn.mp3[a]'

perlin.mp4:
	$(FF) 'perlin=s=$(HD):random_mode=ken,$(TIMER)[v];$(ASRC)rain.mp3[a]'

sierpinski.mp4:
	$(FF) 'sierpinski=s=$(HD):type=triangle,$(TIMER)[v];$(ASRC)weird.mp3[a]'

zoneplate.mp4:
	$(FF) 'zoneplate=s=$(HD):ku=512:kx2=96:xo=-200:kt=8,$(TIMER)[v];$(ASRC)rock2.mp3[a]'

gradients-4k.mp4:
	$(FF) 'gradients=s=$(4K):n=8:t=square,$(TIMER)[v];$(ASRC)sorry.mp3[a]'

gradients.mp4:
	$(FF) 'gradients=s=$(HD):n=8:t=circular,$(TIMER)[v];$(ASRC)sorry.mp3[a]'

gradients-vert.mp4:
	$(FF) 'gradients=s=$(HD):n=8:t=spiral,$(TIMER)[v];$(ASRC)sorry.mp3[a]'

bielue.mp4:
	$(FF) 'color=s=$(TT):c=0x4444ee,$(TIMER)[v];afdelaysrc=d=2[a]'

aclock.mp4:
	$(FF) "color=s=1080x720:c=0xDDFFDD,drawbox=t=24,\
		drawtext=x=(w-text_w)/2:y=(h-text_h)/2:fontsize=256:borderw=4:bordercolor=white:text='%{localtime\:%R}\:%{eif\:t+10\:d}'[v];\
		aevalsrc=2600,volume=2,volume=0:enable=gt(mod(t\,1)\,0.03)[a]"

scroll-vert.mp4: D=drawtext=fontsize=64:fontcolor=0xb89801:x=(w-text_w)/2:y=h-n*2+70*
scroll-vert.mp4:
	$(FF) "life=s=$(TT):ratio=0.04:life_color=white:death_color=black[vb];\
		color=s=$(TT):c=0x00000000,\
		$D0:text='...',\
		$D1:text='Long, long ago,',\
		$D2:text='in a town far,',\
		$D3:text='far away',\
		$D4:text='(at least probably)',\
		$D5:text='someone spent way',\
		$D6:text='too much of their',\
		$D7:text='time creating this',\
		$D8:text='video just for a',\
		$D9:text='simple test case',\
		$D10:text='...',\
		perspective=200:100:W-200:100:-200:H:W+200:H:interpolation=cubic:sense=destination,\
		crop=608:980:0:100,fade=t=out:st=27.5:d=3:alpha=1:c=0x00000000[vt];\
		[vb][vt]overlay=y=100[v];anullsrc[a]"

noaudio.mp4:
	ffmpeg -loglevel error -y -map '[v]' -an -to 30 $@ -filter_complex \
	'perlin=s=$(HD):octaves=3:persistence=2,colorbalance=bh=1:bm=.7:bs=.5[v]'

#######################
#TESTS
#######################
font:
	[ `clips -print=fonts -F 'sans bold italic' | wc -l` -gt 2 ]
	@echo

concat-4k.mp4: TEXT=Concatenate three videos together into one
concat-4k.mp4: mandelbrot-4k.mp4 testsrc-4k.mp4 gradients-4k.mp4
	$(CLIPS) mandelbrot-4k.mp4 0-9 testsrc-4k.mp4 0-9 gradients-4k.mp4 10-19

concat-noaudio.mp4: TEXT=This should be two files concatenated with no audio
concat-noaudio.mp4: noaudio.mp4 life.mp4
	$(CLIPS) { noaudio.mp4 9.300-16.960 life.mp4 18.500-24.900 }

concat-withaudio.mp4: TEXT=This should be two files concatenated with audio
concat-withaudio.mp4: noaudio.mp4 life.mp4
	$(CLIPS) -ddd { life.mp4 9.300-16.960 noaudio.mp4 18.500-24.900 }

fade.mp4: TEXT=Use a fade-in and fade-out affect on a composite video
fade.mp4: zoneplate.mp4 perlin.mp4
	$(CLIPS) fade-in {/c zoneplate.mp4 0-8 perlin.mp4 0-8 } fade-out

grid1.mp4: TEXT=Create a 2x2 grid using vertical and horizontal stacks
grid1.mp4: concat-4k.mp4 mandelbrot-4k.mp4 gradients-4k.mp4 smptebars.mp4
	$(CLIPS) -r:in $(HD) -0 concat-4k.mp4 -1 mandelbrot-4k.mp4       \
		-2 gradients-4k.mp4 -3 smptebars.mp4                        \
		{/v {/h [0]0:05-0:25 [1]0:01-0:21 } {/h [2]0:09-0:29 [3]0:01-0:21 } }

grid2.mp4: TEXT=Create a 2x2 grid using xstack
grid2.mp4: gradients.mp4 sierpinski.mp4 life.mp4 mptest.mp4
	$(CLIPS) {/2x2 gradients.mp4 0-15 sierpinski.mp4 0-15 \
		          life.mp4 0-15 mptest.mp4 0-15 }

overlay-4k.mp4: TEXT=Use the overlay feature to place a small video over another in the center
overlay-4k.mp4: grid2.mp4 aclock.mp4 scroll-vert.mp4
	$(CLIPS) -d grid2.mp4 0-13 \
		'%/10%:40%/0xDDFFDD:0.01:0.03' aclock.mp4 0-20 \
		'%/div(W-w,2):div(H-h,2)' scroll-vert.mp4 scale/$(TT) 0:05-0:25

simple.mp4: TEXT=Simple clip stiching with multiple clips some with audio other without
simple.mp4: zoneplate.mp4 noaudio.mp4 mptest.mp4
	$(CLIPS) zoneplate.mp4 0-0:05 0:07-0:09  noaudio.mp4 0-9 \
		mptest.mp4 0:01-0:03 0:05-0:07 0:27-

flip.mp4: TEXT=A fade-in and fade-out on a video horizontally flipped
flip.mp4: simple.mp4
	$(CLIPS) simple.mp4 fadein/2 flip 0:03.369-16.900 fadeout

transition.mp4: TEXT=A simple 1.8 second transition between two clips
transition.mp4: gradients.mp4
	$(CLIPS) gradients.mp4 0-5.467 /1.8 22.700-

mirror.mp4: TEXT=Geometric shapes transitioned into a vertical mirror
mirror.mp4: sierpinski.mp4
	$(CLIPS) sierpinski.mp4 0-0:10 /2.3/U flip/v 0:07.7-0:17

tro.mp4: TEXT=Testing transition into and out of a vertical stack of videos
tro.mp4: testsrc2-2k.mp4 smptebars.mp4 life.mp4 mptest.mp4
	$(CLIPS) -r $(HD) testsrc2-2k.mp4 0:20-0:25 {/v  \
			smptebars.mp4 crop/1920:540 0-10       \
			life.mp4 crop/1920:540:0:540 0:15-0:25 \
		} mptest.mp4 0-5

groovy.mp4: TEXT=Ungelating clouds with blue transparency over geometric shape
groovy.mp4:
	$(CLIPS) sierpinski.mp4 0-8 %/blue:0.01:0.2 noaudio.mp4 5-13

passthrough.mp4: TEXT=Use an ffmpeg token to call a video filter
passthrough.mp4:
	$(CLIPS) smptebars.mp4 ffmpeg/v/unsharp=7:7:-2:7:7:-2 0-0:15

tteffect1.mp4: TEXT=A verical video walking towards the camera with an affect to fit wide format
tteffect1.mp4:
	$(CLIPS) src/walking.mp4 fade-in {/h                     \
			crop/448:1080:1:280 flip ffmpeg/v/gblur=40 0-  \
			crop/1024:1080:0:280 0-                        \
			crop/448:1080:-1:280 flip ffmpeg/v/gblur=40 0- \
		} fade-out

tteffect2.mp4: TEXT=A verical beach video with another affect to fit wide format
tteffect2.mp4:
	$(CLIPS) src/influencer.mp4 \
			scale/2560:1440/fill crop/2160:2000:0:1000 ffmpeg/v/gblur=50 0- \
			%/'(W-w)\/2':0 scale/1216:1440/fill crop/2160:2560:0:800 0-

carousel.mp4: TEXT=A left scrolling parade of video clips
carousel.mp4: life-vert.mp4 scroll-vert.mp4
	$(CLIPS) -r:in 1080:1920 -1 src/free.mp4 -2 life-vert.mp4      \
		-3 src/walking.mp4 -4 scroll-vert.mp4                     \
		[1] 0-5  /5/L [2] 0-10 /5/L  [3] 0-10 /5/L  [4] 0-10 /5/L \
		[1] 5-15 /5/L [2] 10-20 /5/L [3] 0-10 /5/L  [4] 10-15 

blur.mp4: TEXT=Perform a blur-in and blur-out on a double speed video
blur.mp4: gradients.mp4
	$(CLIPS) gradients.mp4 blur-in speed/2 10-30 blur-out

three.mp4: TEXT=Three videos side by side with black bars on the side to meet the desired resolution
three.mp4: life-vert.mp4 scroll-vert.mp4 zoneplate.mp4
	$(CLIPS) -0 src/free.mp4 -1 scroll-vert.mp4                   \
		-2 life-vert.mp4 -3 zoneplate.mp4 scale/$(HD) {\a        \
		{\h [0] v/0.3 0-10 [1] v/0.8 scale 0-10 [2] v/0.5 5-15 } \
		[3] audio v/2 0- }

text.mp4: TEXT=Three videos with text moving downward
text.mp4: three.mp4
	$(CLIPS) three.mp4 -F 'roman italic' \
		text/blue@0.6/320pt/120:100+n/2-7/'Loren Ipsum' 0-

clipings.mp4: TEXT=Pieces of a single mashup video pulled out and put back together again differently
clipings.mp4: overlay-4k.mp4
	$(CLIPS) overlay-4k.mp4 scale/$(HD) {/h              \
			rotate/L crop/1080:608:276:620 4.083-7.550 \
			crop/608:1080:1616:540         4.083-7.550 \
			crop/608:1080:2320:540         4.083-7.550 \
		}

wind.mp4: TEXT=Two videos with a left wind effect as a transition
wind.mp4: testsrc2-2k.mp4 mandelbrot-4k.mp4
	$(CLIPS) testsrc2-2k.mp4 0-8 /3/hlwind mandelbrot-4k.mp4 0-10

utran.mp4: TEXT=Use a user defined LCUT transition for two different clips
utran.mp4: tro.mp4
	$(CLIPS) -U ../userfilters.clips tro.mp4 0-4 /lcut 8-14

box.mp4: TEXT=Draw a box
box.mp4: bielue.mp4
	$(CLIPS) bielue.mp4 box/10px/#aaaa22cc/2-8/60%:35%:center:middle 0-10

#######################
#ODD BALLS
#######################
hash-a2ec2c90.mp4: TEXT=a simple video resized but with a hash key in the name 
hash-a2ec2c90.mp4: utran.mp4
	clips -S hash-%H.%e -description='$(TEXT)' utran.mp4 scale/2560:1440 0-

novideo.mp3: perlin.mp4 mptest.mp4
	$(CLIPS) -A perlin.mp4 5-15 / mptest.mp4 0-9

