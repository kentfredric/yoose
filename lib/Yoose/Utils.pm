package Yoose::Utils;
use Moose;
use Carp                         ();
use Scalar::Util                 ();
use MooseX::Blessed::Reconstruct ();
use version                      ();
use namespace::clean -except => [qw( has meta )];

our $VERSION = version::qv('0.1');

sub hash_cast {
    my $v = MooseX::Blessed::Reconstruct->new;

    my $plugsub = sub {
        my ( $entity, $class ) = @_;
        if ( Scalar::Util::blessed($entity) ) {
            return $entity if $entity->isa($class);
            Carp::confess(
                'The given entity is of a class different to that required ( Want: '. $class );
        }
        if ( ref $entity ne 'HASH' ) {
            Carp::croak('The given entity is not a hash like expected');
        }
        my $r = bless $entity, $class;
        return $v->visit($r);
    };
    *{Yoose::Utils::hash_cast} = \$plugsub;
    return $plugsub->(@_);
}
1;
