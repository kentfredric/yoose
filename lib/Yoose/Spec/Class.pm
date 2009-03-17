package Yoose::Spec::Class;

# $Id:$

use Moose;
use Scalar::Util ();
use Yoose::Utils ();
use Moose::Util::TypeConstraints;
use Carp    ();
use version ();
our $VERSION = version::qv('0.1');

use namespace::clean -except => [qw( has meta as from via )];

has 'has' => (
    is  => 'rw',
    isa => 'HashRef',
);

subtype 'Yoose.Spec.Class' => ( as 'Yoose::Spec::Class' );

coerce 'Yoose.Spec.Class' => (
    from 'HashRef',
    via {
        Yoose::Utils::hash_cast($_);
    }
);
1;

