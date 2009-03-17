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

sub YAML_is_valid_Yoose($) {
    my $yaml = shift @_;
    unless ( Scalar::Util::blessed($yaml) ) {
        Carp::croak(Yoose::Errors::YAML_was_not_blessed);
    }
    unless ( $yaml->isa('Yoose::Spec') ) {
        Carp::croak(Yoose::Errors::YAML_was_not_blessed_as_spec);
    }
    return 1;
}

sub Object_has_property($$$) {
    my $object        = shift;
    my $property_name = shift;
    my $reason        = shift;
    return 1 if exists $object->{$property_name};
    Carp::croak(
        Yoose::Errors::Object_property_expected( $property_name, $reason ) );
}

sub attribute_is_hash($$$) {
    my $object        = shift;
    my $property_name = shift;
    my $reason        = shift;
    Object_has_property( $object, $property_name, $reason );
    return 1 if ref $object->{$property_name} eq 'HASH';
    Carp::croak(
        Yoose::Errors::Object_property_hash( $property_name, $reason ) );
}
1;

