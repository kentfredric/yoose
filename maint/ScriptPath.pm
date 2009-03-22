package ScriptPath;

# $Id:$

use Moose;
use 5.010;
use version        ();
use File::Spec     ();
use File::Basename ();
use Cwd            ();
use Carp           ();

use namespace::clean -except => [qw( has meta )];

our ($VERSION) = version::qv('0.1');

has 'absolute' => (
    isa        => 'Str',
    is         => 'ro',
    lazy_build => 1,
);
has 'relative' => (
    isa        => 'Str',
    is         => 'ro',
    lazy_build => 1,
);

has 'script_path' => (
    isa        => 'Str',
    is         => 'ro',
    lazy_build => 1,
);
has 'repository_base' => (
    isa        => 'Str',
    is         => 'ro',
    lazy_build => 1,
);
has 'temporary_dir' => (
    isa        => 'Str',
    is         => 'ro',
    lazy_build => 1,
);

sub _build_absolute {
    my $self = shift;
    if ( $self->has_relative ) {
        return File::Spec->catdir( $self->repository_base, $self->relative );
    }
    Carp::croak("Cant Build Absolute Path : ( ");
}

sub _build_relative {
    my $self = shift;
    if ( $self->has_absolute ) {
        return File::Spec->abs2rel( $self->absolute, $self->repository_base );
    }
    Carp::croak("Cant Build Realtive Path :( ");
}

sub _build_script_path {
    return Cwd::realpath(__FILE__);
}

sub _build_repository_base {
    my $self = shift;
    return File::Basename::dirname(
        File::Basename::dirname( $self->script_path ) );
}

sub _build_temporary_dir {
    my $self = shift;
    return File::Spec->catdir( $self->repository_base, '.backup' );
}

sub backup {
    my $self = shift;
    return ScriptPath->new(
        absolute => File::Spec->catdir( $self->temporary_dir, $self->relative )
    );
}

sub tidied {
    my $self = shift;
    return ScriptPath->new(
        absolute => File::Spec->catdir( $self->temporary_dir, $self->relative )
          . '.tidy', );
}

sub diff {
    my $self = shift;
    return ScriptPath->new(
        absolute => File::Spec->catdir( $self->temporary_dir, $self->relative )
          . '.diff', );
}

sub dir {
    my $self = shift;
    return ScriptPath->new(
        absolute => File::Basename::dirname( $self->absolute ) );
}

sub basename {
    my $self = shift;
    return File::Basename::basename( $self->absolute );
}
1;

