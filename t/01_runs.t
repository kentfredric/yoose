#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 1;    # last test to print

use Yoose;

my ($x) = Yoose->new( spec => 't/01_basic.yaml' );

$x->test();
$x->print_out(*STDERR);
print STDERR $x->_open_spec->dump();

ok( 1, "Fake" );

#use Yoose::Spec;
#use YAML::XS;

#print STDERR YAML::XS::Dump( Yoose::Spec->new( classes=> [ 'Yoose::Spec' ] ))
