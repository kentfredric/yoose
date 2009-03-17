package Yoose::Utils;

# $Id:$
use Moose;
use 5.010;
use Carp                         ();
use Scalar::Util                 ();
use Yoose::Assertions            ();
use MooseX::Blessed::Reconstruct ();
use version                      ();
use namespace::clean -except => [qw( has meta )];

our ($VERSION) = version::qv('0.1');

sub hash_cast {
    state $v;
    $v //= MooseX::Blessed::Reconstruct->new;

    my ( $entity, $class ) = @_;
    if ( Scalar::Util::blessed($entity) ) {
        Yoose::Assertions::object_is_blessed( $entity, $class, 'Wrong Type' );
        return $entity;
    }
    Yoose::Assertions::ref_is_hash($entity);
    my $r = bless $entity, $class;
    return $v->visit($r);
}
1;
