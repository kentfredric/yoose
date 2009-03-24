#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Exception;

require Moose;

# This File Contains 1 Package per test-unit.
# Each test unit tests that
#   a) a package can be created using the role
#   b) an instance of the class can be created
#   c) instance->purify() works
#
# The expected Fail Status is controlled by => fail
#   0 being "XPass"
#   1 being "XFail"
#

#
# Each Rule as follows is composed into a package.
# has =>  is mapped to has keys,
# rule => is mapped into the function purfiy_rule
# and fail indicates the expected test result
#
# Rules apply to data in Has
my @tests = (
    Init => {
        has  => {},
        rule => {},
        fail => 0,
    },
    Missing_Attribute => {
        has  => {},
        rule => { alpha => {} },
        fail => 1,
    },
    Missing_TypeCast => {
        has  => { alpha => {qw( isa Str is rw default 1 )}, },
        rule => { alpha => {} },
        fail => 1,
    },
    Bad_Dataset => {
        has  => { alpha => {qw( isa Str is rw default 1 )}, },
        rule => { alpha => { target => 'Test_Init' }, },
        fail => 1,
    },
    Empty_Dataset => {
        has => {
            alpha => {
                isa     => 'HashRef',
                is      => 'rw',
                default => sub {
                    return {};
                },
            },
        },
        rule => { alpha => { target => 'Test_Init' }, },
        fail => 0,
    },
    Bad_DataEntryType => {
        has => {
            alpha => {
                isa     => 'HashRef',
                is      => 'rw',
                default => sub {
                    return { key => 'value', };
                },

            },
        },
        rule => { alpha => { target => 'Test_Init' }, },
        fail => 1,
    },
    Bad_DataEntryClass => {
        has => {
            alpha => {
                isa     => 'HashRef',
                is      => 'rw',
                default => sub {
                    return { key => ( bless {}, 'UNIVERSAL' ), };
                },
            },
        },
        rule => { alpha => { target => 'Test_Init' }, },
        fail => 1,
    },
    Good_DataEntryClass => {
        has => {
            alpha => {
                isa     => 'HashRef',
                is      => 'rw',
                default => sub {
                    return { key => ( bless {}, 'Test_Init' ), };
                },
            },
        },
        rule => { alpha => { target => 'Test_Init' }, },
        fail => 0,
    },
);
my @testkeys = grep { not ref $_ } @tests;
my %tests = @tests;

plan tests => ( scalar @testkeys ) * 3;
for my $testname (@testkeys) {
    my $packagename = "Test_" . $testname;
    lives_ok(
        sub {
            my $meta = Moose->init_meta( for_class => $packagename );

            for my $attribute ( sort keys %{ $tests{$testname}->{has} } ) {

                Moose::has( $packagename, $attribute,
                    %{ $tests{$testname}->{has}->{$attribute} } );

            }

            $meta->add_method(
                purify_rule => sub {
                    return $tests{$testname}->{rule};
                }
            );

            Moose::with( $packagename, 'Yoose::Meta::PureCast' );

            $meta->make_immutable();
        },
        "Generate Package : $testname"
    );
    my $instance;
    lives_ok(
        sub {
            $instance = $packagename->new();
        },
        "Can Create Instances of Rolified Package: $testname"
    );

    if ( $tests{$testname}->{fail} ) {
        dies_ok(
            sub {
                $instance->purify();
            },
            "XFail Purify $testname"
        );
    }
    else {
        lives_ok(
            sub {
                $instance->purify();
            },
            "Can Purify $testname"
        );
    }
}

