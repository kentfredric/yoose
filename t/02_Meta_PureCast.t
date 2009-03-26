#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Exception;
use Moose ();
use Moose::Meta::Class;
use Moose::Meta::Attribute;

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
        fail => 1,    # the rule applies to an attribute which does not exist
    },
    Missing_TypeCast => {
        has  => { alpha => {qw( isa Str is rw default 1 )}, },
        rule => { alpha => {} },
        fail => 1,      # the rule doesn't specify what type to cast into
    },
    Bad_Dataset => {
        has  => { alpha => {qw( isa Str is rw default 1 )}, },
        rule => { alpha => { target => 'Test_Init' }, },
        fail => 1,    # A String cannot be iterated and have its members cast
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
        fail => 1,    # 'value' cannot be cast to an Object
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
        fail => 1
        , # the entry 'Key' is already cast to something, and its not the expected cast
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

# Create the indices in order
# And then make it a hash.
my @testkeys = grep { not ref $_ } @tests;
my %tests = @tests;

plan tests => ( scalar @testkeys ) * 3;

for my $testname (@testkeys) {

    my $metaclass;

    # Generate the Class with Moose

    lives_ok(
        sub {
            $metaclass = generatePackage( $tests{$testname} );
        },
        "Generate Package : $testname"
    );

    my $instance;
    lives_ok(
        sub {

            # innstantiate an  instance of the package.
            $instance = createInstance($metaclass);
        },
        "Can Create Instances of Rolified Package: $testname"
    );

    # Execute Purify

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

sub generatePackage {
    my $testconfig = shift;
    my $metaclass  = Moose::Meta::Class->create_anon_class(
        roles   => ['Yoose::Meta::PureCast'],
        cache   => 0,                         # DO NOT CACHE , CACHE HERE == WTF
        methods => {
            purify_rule => sub {
                return $testconfig->{rule};
            },
        },
    );
    for my $attribute ( sort keys %{ $testconfig->{has} } ) {
        $metaclass->add_attribute( $attribute,
            $testconfig->{has}->{$attribute} );
    }

    $metaclass->calculate_all_roles();
    $metaclass->make_immutable();
    return $metaclass;
}

sub createInstance {
    my $meta = shift;
    return $meta->new_object();
}
