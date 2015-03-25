#!/usr/bin/perl
use strict;
use warnings;
use feature qw( say );
use FindBin qw($Bin);
use lib "$Bin/../lib";

use XML::Twig;

use BLDSS;

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
    say $api->error;
}

my $uin = 'BLL01013337063';

$resp = $api->availability( $uin, { year => 2005 } );

if ($resp) {
    my $xml = XML::Twig->new( pretty_print => 'indented' );
    $xml->parse($resp);
    $xml->print;
}
else {
    say $api->error;
}

$resp = $api->prices;
if ($resp) {
    my $xml = XML::Twig->new( pretty_print => 'indented' );
    $xml->parse($resp);
    $xml->print;
}
else {
    say $api->error->{status} . "\n" . $api->error->{content};
}

$resp = $api->orders;
if ($resp) {
    my $xml = XML::Twig->new( pretty_print => 'indented' );
    $xml->parse($resp);
    $xml->print;
}
else {
    say $api->error;
}
