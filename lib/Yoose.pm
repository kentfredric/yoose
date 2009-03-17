package Yoose;

# $Id:$

use Moose;
use 5.010;
use MooseX::Types::Path::Class ();
use YAML::XS                   ();
use Yoose::Assertions          ();
use version                    ();
use MooseX::YAML               (qw( -xs ));

use namespace::clean -except => [qw( has meta with )];

our ($VERSION) = version::qv('0.1');

with 'MooseX::Log::Log4perl';

# spec : A path to some yaml file that is a Yoose Specification format.
has spec => (
    isa      => 'Path::Class::File',
    is       => 'ro',
    required => 1,
    coerce   => 1,
);

sub _open_spec {
    my $self = shift;
    $self->{__spec} //= do {
        my $newspec = MooseX::YAML::LoadFile( $self->spec->stringify );
        Yoose::Assertions::YAML_is_valid_Yoose($newspec);
        $newspec;
    };
    return $self->{__spec};
}

sub test {
    my $self      = shift;
    my $structure = $self->_open_spec;
    $self->log->debug('Loaded Specification Sucessfully');
    return;
}

sub print_out {
    my $self = shift;
    my $out = shift // *STDOUT;

    # $out is an optional parameter that specifies the output device;
    print $out YAML::XS::Dump( $self->_open_spec->purify );
    return;
}

sub load {
    shift->_open_spec->create;
}
1;

__END__

=head1 Description 

Yoose is a basic framework designed for creating YAML based object specifications.
These are not intended for general purpose functional classes, but more, using a class as
a simple way to organise specifications for structured data. 

Generally, you create a Yoose Specification, which implements a class structure, and then use that 
Yoose Specification to load and validate other YAML files which contain data.

Its basically lots like XML-Schemas in XML, except its for YAML instead.

Additionally, Yoose is backed entirely by Moose, so Yoose specifications are 100% declarative 
Moose specifications. 

=head1 Attributes

=over

=item spec => Path::Class::File

The Path to a YAML file containing the class specificiations.

=back

=head1 Public Methods

=over

=item test 

=item printout

=item printout FD

=item load

=back

=head1 Private Methods

=over

=item _open_spec

=back

=head1 Example

    use Yoose; 
    my $oose = Yoose->new( spec => '/home/my/file.yaml' );
    $oose->load(); 

=head1 Specification Format

    --- !!perl/hash:Yoose::Spec
    classes:
        Classname: ClassSpec

=head2 ClassSpec

    Classname:
        has:
            attribute: attributespec

=head2 AttributeSpec

=cut

=head1 Recommended Reading

=over

=item Moose

=item YAML

=back
