package Yoose::Errors;

# $Id:$

use strict;
use warnings;
use version;
use namespace::clean;

our ($VERSION) = version::qv('0.1');

## no critic ( SubroutinePrototypes )
sub yaml_was_not_blessed() {
    'YAML File was not an Object, expected !!perl/hash:Yoose::Spec';
}

sub yaml_was_not_blessed_as_spec() {
    'Non-Yoose Spec File Provided';
}

sub object_property_expected($$) {
    sprintf
'A property "%s" was expected on the passed object but none was found ( reason: %s )',
      @_;
}

sub object_property_hash($$) {
    sprintf 'The Property "%s" was expected to be of type "HASH" ', @_;
}

sub object_is_bless($) {
    sprintf 'The Given Object was not a "blessed" object ( reason: "%s" )', @_;
}

sub object_is_blessed($$) {
    sprintf 'The Given Object was not of type "%s"( reason: "%s" )', @_;
}

sub ref_is_not_hash() {
    'The reference specified does not point to a "hash" ';
}
1;

