#!/usr/bin/perl

package FFUtils;

our($VERSION)='$Id';

use IO::Handle;
use List::Util;

my(@FFMPEG)=qw(ffmpeg -y -ac 2 -stats_period);
my($PERIOD)=6;
my(@FFLOG)=qw(-loglevel fatal -progress -);

our($DEBUG)=0;
our($NORMALIZE)='loudnorm,dynaudnorm,highpass=f=600';

my($MB)=2**20;

sub time2secs {
	local($_)=@_;

	if(m/^([\d-]+):(\d+):([\d.]+)$/) {
		return($1*3600+$2*60+$3);
	} elsif(m/^([\d-]+):([\d.]+)$/) {
		return($1*60+$2);
	} elsif(m/^([\d.-]+)s?$/) {
		return($1);
	} elsif(m/^([\d.-]+)ms$/) {
		return($1/1000);
	} elsif(m/^([\d.-]+)us$/) {
		return($1/1000000);
	} else {
		print STDERR "Invalid time format ($_)\n";
		return(0);
	}
}

sub secs2time {
	my($secs)=@_;
	my($time)=sprintf("%d:%02d:%02d.%1d",
		$secs/3600, (($secs/60)%60), $secs%60, ($secs*10)%10);
	$time=~s/^[0:]+(?=\d+:)//;

	return($time);
}

sub probe {
	my($file, $key, $value)=@_;
	my($probe)=IO::Handle->new;
	my(@ffprobe)=qw(ffprobe -show_streams -v quiet);
	my($output)=undef;

	$value='.+' unless($value);

	return(undef) unless(-r $file);

	open($probe, '-|', @ffprobe, $file);
	while(<$probe>) {
		if(m/^$key=($value)/) {
			$output=$1;
			last;
		}
	}
	close($probe);

	if($output=~m|([\d.]+)/([\d.]+)|) {
		$output=$1/$2 if($2);
	}
	return($output);
}

sub has_video {
	my($file)=@_;
	my($probe)=IO::Handle->new;
	my(@ffprobe)=qw(ffprobe -show_streams -v quiet);
	my($video)=undef;
	local($/)='[/STREAM]';

	if(-r $file) {
		open($probe, '-|', @ffprobe, $file);
		while(<$probe>) {
			if(m/^codec_type=video/m) {
				$video=1 if(m/^avg_frame_rate=[1-9]/m);
				$video=1 if(m/^nal_length_size=\d/m);
			}
		}
		close($probe);
	}

	return($video);
}

sub has_audio {
	return(&probe($_[0], 'codec_type', 'audio') eq 'audio');
}

sub shortest {
	return(List::Util::min(map(&duration($_), @_)));
}

sub duration {
	my(@tags)=qw(duration TAG:DURATION);
	my($duration);

	foreach my $tag (@tags) {
		$duration=&probe($_[0], $tag);
		return(&time2secs($duration)) if($duration=~m/^[\d:.]+$/);
	}
	return(undef);
}

sub width {
	return(&probe($_[0], 'width'));
}

sub height {
	return(&probe($_[0], 'height'));
}

sub framerate {
	return(&probe($_[0], 'r_frame_rate'));
}

sub bounded_attribute {
	my($min, $attr, $max, @files)=@_;

	return(
		List::Util::min(
			$max,
			List::Util::max(
				$min,
				map(&probe($_, $attr), @files)
			)
		)
	);
}

sub target_height {
	return(&bounded_attribute(1080, 'height', 2160, @_));
}

sub target_fps {
	return(&bounded_attribute(24, 'r_frame_rate', 60, @_));
}

sub status {
	my($progress, $new)=@_;
	my($size, $time, $elapse, $pct);
	my($zero)=undef;
	local($/)='progress=continue';
	local($|)=1;

	STDOUT->autoflush(1);

	print "Preprocessing ";

	while(<$progress>) {
		unless($zero) {
			$zero=time()-$PERIOD;
			printf("(%s)\n\n%24s%7s%9s%20s\n", &secs2time(time()-$^T),
				'Encoded/Target', 'Pct', 'Size', 'Elapsed/Expected');
		}

		if(($size, $time)=m/total_size=(\d+).*out_time_ms=(\d+)/s) {
			$time/=1000000;
			$elapse=(time()-$zero)/60;
			$pct=$time/$new;

			printf("\r%s: %7s/%-7s, %3d%%, %4d MB, %5.1f min/%-5.1f min  ",
				$progress->eof()?'Complete':'Progress',
				&secs2time($time), &secs2time($new), $pct*100,
				$1/$MB, $elapse, $elapse/$pct) if($pct);
		}
	}
	close($progress);

	print "\n";

}

sub cmdline {
	my(@cmd)=@_;
	local($_);

	splice(@cmd, 0, 0, @FFMPEG, $PERIOD);

	foreach(@cmd) {
		if(m/[\s;*?&\[\]]/) {
			s/^/"/;
			s/$/"/;
		}
	}

	return(join(' ', @cmd));
}

sub ffmpeg {
	my($PROGRESS)=IO::Handle->new;
	my($out)=pop(@_);

	if($DEBUG>0) {
		print "\n\n", &cmdline(@_, $out), "\n\n";
	}

	if(-r $out) {
		print STDERR "'$out' exists, overwritting in 3 seconds...\n";
		sleep(3);
	}

	open($PROGRESS, '-|', @FFMPEG, $PERIOD, @FFLOG, @_, $out);

	return($PROGRESS);
}

1;
