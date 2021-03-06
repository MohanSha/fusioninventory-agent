package FusionInventory::Agent::Target::Server;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);
use URI;

my $count = 0;

sub new {
    my ($class, %params) = @_;

    die "no url parameter for server target\n" unless $params{url};

    my $self = $class->SUPER::new(%params);

    $self->{url} = _getCanonicalURL($params{url});

    # compute storage subdirectory from url
    my $subdir = $self->{url};
    $subdir =~ s/\//_/g;
    $subdir =~ s/:/../g if $OSNAME eq 'MSWin32';

    $self->_init(
        id     => 'server' . $count++,
        vardir => $params{basevardir} . '/' . $subdir
    );

    return $self;
}

sub _getCanonicalURL {
    my ($string) = @_;

    my $url = URI->new($string);

    my $scheme = $url->scheme();
    if (!$scheme) {
        # this is likely a bare hostname
        # as parsing relies on scheme, host and path have to be set explicitely
        $url->scheme('http');
        $url->host($string);
        $url->path('ocsinventory');
    } else {
        die "invalid protocol for URL: $string"
            if $scheme ne 'http' && $scheme ne 'https';
        # complete path if needed
        $url->path('ocsinventory') if !$url->path();
    }

    return $url;
}

sub getUrl {
    my ($self) = @_;

    return $self->{url};
}

sub getName {
    my ($self) = @_;

    return $self->{url};
}

sub getType {
    my ($self) = @_;

    return 'server';
}

sub plannedTasks {
    my $self = shift @_;

    # Server can trigger any task
    if (@_) {
        $self->{tasks} = [ @_ ];
    }

    return @{$self->{tasks} || []};
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target::Server - Server target

=head1 DESCRIPTION

This is a target for sending execution result to a server.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, in addition to those
from the base class C<FusionInventory::Agent::Target>, as keys of the %params
hash:

=over

=item I<url>

the server URL (mandatory)

=back

=head2 getUrl()

Return the server URL for this target.

=head2 getName()

Return the target name

=head2 getType()

Return the target type

=head2 plannedTasks([@tasks])

Initializes target tasks with supported ones if a list of tasks is provided

Return an array of planned tasks.
