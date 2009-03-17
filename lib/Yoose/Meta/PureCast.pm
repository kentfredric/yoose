package Yoose::Meta::PureCast;

use Moose::Role;
use Yoose::Utils      ();
use Carp              ();
use Scalar::Util      ();
use Yoose::Assertions ();

use namespace::clean -except => [qw( meta requires )];

requires 'purify_rule';

sub _purify_expand {
    my ( $self, $rule, $rulename ) = @_;
    Yoose::Assertions::Object_has_property( $self, $rulename,
        'Cant apply rules with no property to apply them on' );
    Yoose::Assertions::Object_has_property( $rule, 'target',
        'Cannot cast into something without a something to cast into' );

    $rule->{list_rule}     //= 'Hash';
    $rule->{possible_from} //= 'Hash';
    $rule->{recurse}       //= 0;

    return $rule;
}

sub _purify_hash_hash {
    my ( $self, $property, $target, $recurse ) = @_;
    Yoose::Assertions::attribute_is_hash( $self, $property,
        'Need to be Hashes to purify them.' );
    my $data = $self->{$property};
    foreach my $item ( keys %{$data} ) {
        $data->{$item} = Yoose::Utils::hash_cast( $data->{$item}, $target );
        next if not $recurse;
        next if not Scalar::Utils::blessed $data->{$item};
        next if not $data->{$item}->can('purify');
        $data->{$item}->purify();
    }
}

sub purify {
    my $self         = shift;
    my %purification = %{ $self->purify_rule() };
    foreach my $property ( keys %purification ) {
        my $rule = $self->_purify_expand( $purification{$property}, $property );
        if ( $rule->{list_rule} eq 'Hash' and $rule->{possible_from} eq 'Hash' )
        {
            $self->_purify_hash_hash( $property, $rule->{target},
                $rule->{recurse}, );
            next;
        }
    }
    return $self;
}

1;
