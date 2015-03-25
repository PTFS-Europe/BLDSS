#!/usr/bin/perl
use strict;
use warnings;
use feature qw( say );
use FindBin qw($Bin);
use lib "$Bin/../lib";

use XML::Twig;

use BLDSS;

use Data::Dump qw(dump);

my $api = BLDSS->new();

#my $resp = $api->simple_search('slovenia');
my $resp = $api->search('European AND political');

#my $resp = $api->search('European AND political', { start_rec => 2});

if ($resp) {
    my $xml = XML::Twig->new( pretty_print => 'indented' );
    $xml->parse($resp);
    $xml->print;
}
else {
    say dump $api->error;
}

my $uin = 'BLL01013337063';

$resp = $api->availability( $uin, { year => 2005 } );

if ($resp) {
    my $xml = XML::Twig->new( pretty_print => 'indented' );
    $xml->parse($resp);
    $xml->print;
}
else {
    say dump $api->error;
}

$resp = $api->prices;
if ($resp) {
    my $xml = XML::Twig->new( pretty_print => 'indented' );
    $xml->parse($resp);
    $xml->print;
}
else {
    say dump $api->error;
}

$resp = $api->orders;
if ($resp) {
    my $xml = XML::Twig->new( pretty_print => 'indented' );
    $xml->parse($resp);
    $xml->print;
}
else {
    say dump $api->error;
}

$resp = $api->create_order( {
    customerReference => 19,
    Delivery => {
        Address => {
            AddressLine1     => "Jefferson Summit",
            AddressLine2     => "",
            AddressLine3     => "",
            Country          => "",
            CountyOrState    => "",
            PostOrZipCode    => "",
            ProvinceOrRegion => "",
            TownOrCity       => "",
        },
        email   => "",
    },
    Item => { uin => "BLL01016905070" },
    requestor => "Tommy Peters",
    service => { format => 4, quality => 1, quantity => 1, service => 1, speed => 2 },
    type => "A",
} );
if ($resp) {
    my $xml = XML::Twig->new( pretty_print => 'indented' );
    $xml->parse($resp);
    $xml->print;
}
else {
    say dump $api->error;
}
