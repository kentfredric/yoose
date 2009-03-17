package Yoose::Assertions;

# $Id:$
use strict;
use warnings;
use 5.010;
use version       ();
use Yoose::Errors ();
use Scalar::Util  ();
use Carp          ();
use namespace::clean;

our ($VERSION) = version::qv('0.1');
## no critic ( SubroutinePrototypes )
sub yaml_is_valid_yoose($) {
    my $yaml = shift @_;
    object_is_bless( $yaml, Yoose::Errors::yaml_was_not_blessed );
    object_is_blessed( $yaml, 'Yoose::Spec',
        Yoose::Errors::yaml_was_not_blessed_as_spec );
    return 1;
}

sub object_has_property($$$) {
    my $object        = shift;
    my $property_name = shift;
    my $reason        = shift;
    return 1 if exists $object->{$property_name};
    Carp::confess Yoose::Errors::object_property_expected( $property_name,
        $reason );
}

sub attribute_is_hash($$$) {
    my $object        = shift;
    my $property_name = shift;
    my $reason        = shift;
    object_has_property( $object, $property_name, $reason );
    return 1 if ref $object->{$property_name} eq 'HASH';
    Carp::confess Yoose::Errors::object_property_hash( $property_name,
        $reason );
}

sub object_is_blessed($$$) {
    my $object     = shift;
    my $blessed_as = shift;
    my $reason     = shift;
    unless ( $object->isa($blessed_as) ) {
        Carp::confess Yoose::Errors::object_is_blessed( $blessed_as, $reason );
    }
}

sub object_is_bless($$) {
    my $object = shift;
    my $reason = shift;
    unless ( Scalar::Util::blessed($object) ) {
        Carp::confess Yoose::Errors::object_is_bless($reason);
    }
    return 1;
}

sub ref_is_hash($) {
    my $object = shift;
    unless ( ref $object eq 'HASH' ) {
        Carp::confess Yoose::Errors::ref_is_not_hash;
    }
}
1;

