#!/usr/bin/perl 

use strict;
use warnings;
use 5.010;
use version          ();
use File::Find::Rule ();
use File::Copy       ();
use File::Path       ();
use Perl::Tidy       ();
use Carp             ();
use lib 'maint';
use DirTraverse ();
use namespace::clean;

our ($VERSION) = version::qv('0.1');

my %messages = (
    copy_dir        => "Cp_in : => %s \n",
    copy            => "Cp    : => %s \n",
    error_copy      => "Error : Copy Failed \n",
    mkdir_recursive => "Mkdir : => %s\n",
    sep             => "---\n",
    tidy            => "Tidy  : => %s \n",
    file            => "File  : <= %s\n",
    diff            => "Diff  : => %s \n",
);

sub diff {
    my ( $left, $right, $out ) = @_;
    my $fh;
    open $fh, '-|', 'diff', '-Naur', $left, $right;
    return $fh;
}

DirTraverse::perlfiles {
    printf $messages{file},            $_->relative;
    printf $messages{copy_dir},        $_->backup->dir->relative;
    printf $messages{mkdir_recursive}, $_->backup->dir->relative;
    File::Path::mkpath( $_->backup->dir->absolute );

    printf $messages{copy}, $_->backup->relative;

    if ( not File::Copy::copy( $_->absolute, $_->backup->absolute ) ) {
        Carp::croak( $messages{error_copy} );
    }
    printf $messages{tidy}, $_->tidied->relative;
    Perl::Tidy::perltidy(
        source      => $_->backup->absolute,
        destination => $_->tidied->absolute,
    );
    printf $messages{diff}, $_->diff->relative;
    my $fh = diff $_->backup->absolute, $_->tidied->absolute;
    my $lc = 0;
    while ( my $line = <$fh> ) {
        print $line;
        $lc++;
    }
    close($fh);
    if ( $lc > 0 ) {
        print "Apply? Y /  N\n";
        while ( my $l = <STDIN> ) {
            last if $l =~ /^N/i;
            next if $l !~ /^Y/i;
            print "Ok\n";
            File::Copy::copy( $_->tidied->absolute, $_->absolute );
            last;
        }
    }

    print $messages{sep};
};

