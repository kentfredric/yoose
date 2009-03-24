#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Exception;

# This File Contains 1 Package per test-unit.
# Each test unit tests that
#   a) an instance of the class can be created
#   b) instance->purify() works
#
# The expected Fail Status is controlled by ->fails()
#   0 being "XPass"
#   1 being "XFail"
#
my @t = ();
{

    package Test_Init;
    use Moose;

    with 'Yoose::Meta::PureCast';

    sub purify_rule {
        return {

        };
    }
    sub fails { return 0; }
    push @t, __PACKAGE__;
}
{

    package Test_Missing_Attribute;
    use Moose;

    with 'Yoose::Meta::PureCast';

    sub purify_rule {
        return { alpha => {} };
    }
    sub fails { return 1; }
    push @t, __PACKAGE__;
}
{

    package Test_Missing_TypeCast;
    use Moose;

    with 'Yoose::Meta::PureCast';

    has alpha => (
        isa     => 'Str',
        is      => 'rw',
        default => '1',
    );

    sub purify_rule {
        return { alpha => {} };
    }
    sub fails { return 1; }
    push @t, __PACKAGE__;
}

{

    package Test_Bad_Dataset;
    use Moose;

    with 'Yoose::Meta::PureCast';

    has alpha => (
        isa     => 'Str',
        is      => 'rw',
        default => '1',
    );

    sub purify_rule {
        return { alpha => { target => 'Test_Init', } };
    }
    sub fails { return 1; }
    push @t, __PACKAGE__;
}
{

    package Test_Empty_Dataset;
    use Moose;

    with 'Yoose::Meta::PureCast';

    has alpha => (
        isa     => 'HashRef',
        is      => 'rw',
        default => sub { {} },
    );

    sub purify_rule {
        return { alpha => { target => 'Test_Init', } };
    }
    sub fails { return 0; }
    push @t, __PACKAGE__;
}
{

    package Test_Bad_DataEntryType;
    use Moose;

    with 'Yoose::Meta::PureCast';

    has alpha => (
        isa     => 'HashRef',
        is      => 'rw',
        default => sub {
            { key => 'value', };
        },
    );

    sub purify_rule {
        return { alpha => { target => 'Test_Init', } };
    }
    sub fails { return 1; }
    push @t, __PACKAGE__;
}
{

    package Test_Bad_DataEntryClass;
    use Moose;

    with 'Yoose::Meta::PureCast';

    has alpha => (
        isa     => 'HashRef',
        is      => 'rw',
        default => sub {
            { key => ( bless {}, 'UNIVERSAL' ), };
        },
    );

    sub purify_rule {
        return { alpha => { target => 'Test_Init', } };
    }
    sub fails { return 1; }
    push @t, __PACKAGE__;
}
{

    package Test_Good_DataEntry;
    use Moose;

    with 'Yoose::Meta::PureCast';

    has alpha => (
        isa     => 'HashRef',
        is      => 'rw',
        default => sub {
            { key => {}, };
        },
    );

    sub purify_rule {
        return { alpha => { target => 'Test_Init', } };
    }
    sub fails { return 0; }
    push @t, __PACKAGE__;
}
{

    package Test_Good_DataEntryClass;
    use Moose;

    with 'Yoose::Meta::PureCast';

    has alpha => (
        isa     => 'HashRef',
        is      => 'rw',
        default => sub {
            { key => ( bless {}, 'Test_Init' ), };
        },
    );

    sub purify_rule {
        return { alpha => { target => 'Test_Init', } };
    }
    sub fails { return 0; }
    push @t, __PACKAGE__;
}

# -- End Tests
# -- Run Tests

plan tests => ( scalar @t ) * 2;
for (@t) {

    my $o;
    lives_ok {
        $o = $_->new();
    }
    'Can Instantiate: ' . $_;

    if ( $o->fails() ) {
        dies_ok {
            $o->purify();
        }
        'Fails Purify   : ' . $_;
    }
    else {
        lives_ok {
            $o->purify;
        }
        'Can Purify     : ' . $_;
    }
}
