package FusionInventory::Agent::SNMP::MibSupport::Epson;

use strict;
use warnings;

use parent 'FusionInventory::Agent::SNMP::MibSupportTemplate';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::SNMP;

use constant    epson   => '.1.3.6.1.4.1.1248' ;
use constant    model   => epson  .'.1.2.2.1.1.1.2.1' ;
use constant    serial  => epson  .'.1.2.2.1.1.1.5.1' ;
use constant    fw_base => epson . '.1.2.2.2.1.1' ;

our $mibSupport = [
    {
        name        => "epson-printer",
        sysobjectid => getRegexpOidMatch(epson)
    }
];

sub getSerial {
    my ($self) = @_;

    return $self->get(serial);
}

sub getModel {
    my ($self) = @_;

    return $self->get(model)
}

sub run {
    my ($self) = @_;

    my $device = $self->device
        or return;

    my $versions  = $self->walk(fw_base.'.2') || {};
    my $names     = $self->walk(fw_base.'.3') || {};
    my $firmwares = $self->walk(fw_base.'.4') || $names;
    if ($firmwares) {
        foreach my $index (keys(%{$firmwares})) {
            next unless $versions->{$index};
            my $firmware = {
                NAME            => "Epson ".($names->{$index} || "printer"),
                DESCRIPTION     => "Epson printer ".($names->{$index} || "firmware"),
                TYPE            => "printer",
                VERSION         => $versions->{$index},
                MANUFACTURER    => "Epson"
            };
            $device->addFirmware($firmware);
        }
    }
}

1;

__END__

=head1 NAME

Inventory module for Epson Printers

=head1 DESCRIPTION

The module enhances Epson printers devices support.
