#!/usr/bin/perl
use strict;
use warnings;

use Test::More;

BEGIN { use_ok('BLDSS::Config'); }

my $class = 'BLDSS::Config';

my ( $api_key, $api_key_auth, $api_application, $api_application_auth )
    = qw( 1234 test 5678 tset );

my $conf_obj = $class->new(
    {
        api_key              => $api_key,
        api_key_auth         => $api_key_auth,
        api_application      => $api_application,
        api_application_auth => $api_application_auth
    }
);

isa_ok( $conf_obj, $class );

is( $conf_obj->api_key, $api_key, "API Key method" );

is( $conf_obj->api_application, $api_application, "API Application method" );

is(
    $conf_obj->hashing_key,
    join("&", $api_application_auth, $api_key_auth),
    "Hashing Key method"
);

done_testing;
