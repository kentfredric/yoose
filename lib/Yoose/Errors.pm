package Yoose::Errors;

# $Id:$

use strict;
use warnings;
use version;
use namespace::clean;

our ($VERSION) = version::qv('0.1');

sub YAML_was_not_blessed() {
    'YAML File was not an Object, expected !!perl/hash:Yoose::Spec';
}

sub YAML_was_not_blessed_as_spec() {
    'Non-Yoose Spec File Provided';
}

sub Object_property_expected($$){ 
    sprintf 'A property "%s" was expected on the passed object but none was found ( reason: %s )', @_; 
}

sub Object_property_hash($$){ 
    sprintf 'The Property "%s" was expected to be of type "HASH" ' , @_ ; 
}
1;

