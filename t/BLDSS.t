#!/usr/bin/perl
use strict;
use URI;
use warnings;

use Test::More;

BEGIN { use_ok( 'BLDSS' ); }

my $class = 'BLDSS';

my $api_obj = $class->new();

isa_ok($api_obj, $class);

my $resp = $api_obj->search('slovenia');

my $r_start = q{<?xml version="1.0" encoding="UTF-8"?><apiResponse.};
my $start_len = length $r_start;
my $string = substr $resp, 0, $start_len;

cmp_ok($string, 'cmp', $r_start, 'SimpleSearch received response');

# Hashing Key
is( $api_obj->{config}->hashing_key, "m7eZz1CCu7&APIDEV176", "Hashing Key" );

# _Authentication_Header
is(
    $api_obj->_authentication_header(
        {
            method => "GET",
            uri    => URI->new($api_obj->{api_url} . '/api/prices'),
            return => "parameter_string",
            nonce  => "dgkjzPxUElpGmWhQ",
            time   => "1424880494",
        }
    ),
    "api_application=BLAPI8IJdN&api_key=87-0656&nonce=dgkjzPxUElpGmWhQ&override_encoding_method=on&request_time=1424880494&signature_method=HMAC-SHA1",
    "_authentication_header parameter string check"
);

is(
    $api_obj->_authentication_header(
        {
            method => "GET",
            uri    => URI->new($api_obj->{api_url} . '/api/prices'),
            return => "request_string",
            nonce  => "dgkjzPxUElpGmWhQ",
            time   => "1424880494",
        }
    ),
    "GET&%2Fapi%2Fprices&api_application%3DBLAPI8IJdN%26api_key%3D87-0656%26nonce%3DdgkjzPxUElpGmWhQ%26override_encoding_method%3Don%26request_time%3D1424880494%26signature_method%3DHMAC-SHA1",
    "_authentication_header request string check"
);

is(
    $api_obj->_authentication_header(
        {
            method => "GET",
            uri    => URI->new($api_obj->{api_url} . '/api/prices'),
            return => "authorisation_string",
            nonce  => "dgkjzPxUElpGmWhQ",
            time   => "1424880494",
        }
    ),
    "I+dIhOt0T3wlhS45utwxYMJTxng=",
    "_authentication_header authorisation string check"
);

my $header = $api_obj->_authentication_header(
        {
            method => "GET",
            uri    => URI->new($api_obj->{api_url} . '/api/prices'),
            nonce  => "dgkjzPxUElpGmWhQ",
            time   => "1424880494",
        }
    );
my @sortedHeader = sort { lc($a) cmp lc($b) } split(/,/, $header);
my @sortedResult = sort { lc($a) cmp lc($b) } split(/,/, "api_application=BLAPI8IJdN,nonce=dgkjzPxUElpGmWhQ,signature_method=HMAC-SHA1,request_time=1424880494,authorisation=I+dIhOt0T3wlhS45utwxYMJTxng=,override_encoding_method=on,api_key=87-0656");

is( @sortedHeader, @sortedResult, "_authentication_header, Complete Header" );

done_testing;
