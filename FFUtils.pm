#!/usr/bin/perl

package FFUtils;

our($VERSION)='1.0';

use IO::Handle;
use List::Util;
use JSON;

my(@FFMPEG)=qw(ffmpeg -y -ac 2 -progress - -stats_period);
my($PERIOD)=6;
my(@FFLOG)=qw(-loglevel error);
my(%DB)=();

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

sub get_info {
	my($file)=@_;
	my($probe)=IO::Handle->new;
	my(@ffprobe)=qw(ffprobe -of json -v quiet -show_format -show_streams);
	my(@fractions)=qw(r_frame_rate avg_frame_rate time_base);
	my($info);
	local($/)=undef;
	
	return(undef) unless(-r $file);

	unless($DB{$file}) {
		open($probe, '-|', @ffprobe, '-select_streams', 'v', $file);
		$info=eval {JSON->new->decode(join('', <$probe>))} || {};
		$DB{$file}{'video'}=$info->{'streams'}[0];
		$DB{$file}{'format'}=$info->{'format'};
		close($probe);

		open($probe, '-|', @ffprobe, '-select_streams', 'a', $file);
		$info=eval {JSON->new->decode(join('', <$probe>))} || {};
		$DB{$file}{'audio'}=$info->{'streams'}[0];
		$DB{$file}{'format'}||=$info->{'format'};
		close($probe);

		foreach my $type (keys(%{$DB{$file}})) {
			for my $key (@fractions) {
				if($DB{$file}{$type}{$key}=~m|([\d.]+)/([\d.]+)|) {
					$DB{$file}{$type}{$key}=$1/$2 if($2);
				}
			}
		}
	}

	return($DB{$file});
}

sub probe {
	my($file, $key, $value)=@_;
	my($probe)=IO::Handle->new;
	my(@types)=qw(format video audio);
	my($db)=&get_info($file);

	if($key=~m/^\s*(\w+)\W+(\w+)\s*$/) {
		@types=($1);
		$key=$2;
	}

	foreach my $type (@types) {
		if(exists($db->{$type}{$key})) {
			if(defined($value)) {
				if($db->{$type}{$key}=~m/$value/i) {
					return($db->{$type}{$key});
				}
			} else {
				return($db->{$type}{$key});
			}
		}
	}

	return(undef);
}

sub has_video {
	my($video)=&get_info(@_)->{'video'};

	return(
		$video &&
		$video->{'width'} &&
		$video->{'height'} &&
		$video->{'avg_frame_rate'}
	);
}

sub has_audio {
	my($audio)=&get_info(@_)->{'audio'};

	return( $audio && $audio->{'codec_type'} eq 'audio' );
}

sub shortest {
	return(List::Util::min(map(&duration($_), @_)));
}

sub duration {
	my($duration)=&probe($_[0], 'duration');

	if($duration=~m/^[\d:.]+$/) {
		return(&time2secs($duration));
	} else {
		return(undef);
	}
}

sub width {
	return(&probe($_[0], 'video:width'));
}

sub height {
	return(&probe($_[0], 'video:height'));
}

sub framerate {
	return(&probe($_[0], 'video:r_frame_rate'));
}

sub clamp {
	my($l, $v, $h)=@_;

	return(  ($v<$l) ? $l : ($v>$h) ? $h : $v );
}

sub bounded_attribute {
	my($min, $attr, $max, $file)=@_;

	return(&clamp($min, &probe($file, $attr), $max));
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
