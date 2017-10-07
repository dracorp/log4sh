#!/usr/bin/env perl

use strict;
use warnings;

use POSIX qw(strftime);
use Time::HiRes qw(time);
use English qw( -no_match_vars );

sub parseCommandLineOptions {
    my ( $option ) = @ARG;
    for my $index (0 .. $#ARGV) {
        if ($ARGV[$index] eq '-u') {
            $option->{utc} = 1;
        }
        elsif ($ARGV[$index] =~ /\+%/) {
            ( $option->{format} ) = $ARGV[$index] =~ m/\+(.*)/;
        }
        elsif ($ARGV[$index] =~ /%/ && $ARGV[$index] !~ /\+/) {
            print "date: invalid date $ARGV[$index]\n";
            exit 1;
        }
        elsif ( $ARGV[$index] =~ /^-d[^ ]+/ ) {
            ( $option->{date} ) = $ARGV[$index] =~ m/-d@?(.*)/;
        }
        elsif ( $ARGV[$index] =~ /^-d$/ ) {
            ( $option->{date} ) = $ARGV[$index+1] =~ m/@?(.*)/;
        }
    }
}

my $option = {
    format => '%a %b %e %H:%M:%S %Z %Y',
};

parseCommandLineOptions($option);

my $time;
if ( $option->{date} ) {
    $time = $option->{date};
}
else {
    if ( $option->{utc} ) {
        $time = sprintf '%.9f', gmtime();
    }
    else {
        $time = sprintf '%.9f', time();
    }
}
my ( $nsec ) = $time =~ m/\.(.*)/;
my @time = localtime $time;
my $nsecFlag;
if ( $option->{format} =~ m/%N$/ ) {
    $option->{format} =~ s/%N//;
    $nsecFlag = 1;
}
my $formatedTime = strftime "$option->{format}", @time;
if ( $nsecFlag ) {
    $formatedTime .= $nsec;
}
print $formatedTime, "\n";

__END__

=head1 NAME

date.pl - simple GNU date replacement

=head1 SYNOPSIS

date.pl -u format -d@date

=head1 EXAMPLE

date.pl -u '%F-%T' -d@1234567

=head1 AUTHOR

Piotr Rogoza

=cut
