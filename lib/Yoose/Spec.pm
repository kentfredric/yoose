package Yoose::Spec;

# $Id:$

use Moose;
use Moose::Util::TypeConstraints;
use Yoose::Spec::Class ();
use Yoose::Utils       ();
use version            ();

use namespace::clean -except => [qw( has meta coerce)];
our ($VERSION) = version::qv('0.1');

with 'Yoose::Meta::PureCast';

has 'classes' => (
    is     => 'rw',
    isa    => 'HashRef',
    coerce => 1,
);

sub purify_rule {
    return { classes => { target => 'Yoose::Spec::Class' } };
}

1;

