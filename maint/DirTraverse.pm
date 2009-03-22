package DirTraverse;

# $Id:$

use 5.010;
use strict;
use warnings;
use version ();

use Carp ();
use lib 'maint';
use ScriptPath ();

use namespace::clean -except => [qw( has meta )];
our ($VERSION) = version::qv('0.1');

sub matching(@$) {
    my @keys = @{ $_[0] };
    shift;
    my $cb = shift;
    my @subdirs = map { ScriptPath->new( relative => $_ ) } qw(
      lib
      t
      maint
    );
    my $finder = File::Find::Rule->name(@keys);
    $finder->start( map { $_->absolute } @subdirs );

    while ( my $file = $finder->match ) {
        local $_ = ScriptPath->new( absolute => $file );
        $cb->($_);
    }
    return;

}

sub perlfiles(&) {
    my $cb = shift;
    matching( [ '*.pl', '*.pm', '*.t' ], $cb );

    return;
}

1;

