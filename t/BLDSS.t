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
is( $api_obj->{config}->hashing_key, "m7eZz1CCu7&API1394039", "Hashing Key" );

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
    "api_application=BLAPI8IJdN&api_key=73-0013&nonce=dgkjzPxUElpGmWhQ&override_encoding_method=on&request_time=1424880494&signature_method=HMAC-SHA1",
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
    "GET&%2Fapi%2Fprices&api_application%3DBLAPI8IJdN%26api_key%3D73-0013%26nonce%3DdgkjzPxUElpGmWhQ%26override_encoding_method%3Don%26request_time%3D1424880494%26signature_method%3DHMAC-SHA1",
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
    "VQ/CUButHZnTUlxcqvoE6EEzvn8=",
    "_authentication_header authorisation string check"
);

is(
    $api_obj->_authentication_header(
        {
            method => "POST",
            uri    => URI->new($api_obj->{api_url} . '/api/orders'),
            return => "parameter_string",
            nonce  => "dgkjzPxUElpGmWhQ",
            time   => "1424880494",
            request_body => "<NewOrderRequest><type>A</type><requestor>Tommy Peters</requestor><customerReference>19</customerReference><Delivery><email/><Address><AddressLine1>Jefferson Summit</AddressLine1><AddressLine2/><AddressLine3/><TownOrCity/><CountyOrState/><ProvinceOrRegion/><PostOrZipCode/><Country/></Address></Delivery><Item><uin>BLL01016905070</uin><titleLevel/><itemLevel/><itemOfInterestLevel/></Item><Service><service>1</service><format>4</format><speed>2</speed><quality>1</quality><quantity>1</quantity></Service></NewOrderRequest>",
        }
    ),
    "api_application=BLAPI8IJdN&api_key=73-0013&nonce=dgkjzPxUElpGmWhQ&override_encoding_method=on&request=%3CNewOrderRequest%3E%3Ctype%3EA%3C%2Ftype%3E%3Crequestor%3ETommy%20Peters%3C%2Frequestor%3E%3CcustomerReference%3E19%3C%2FcustomerReference%3E%3CDelivery%3E%3Cemail%2F%3E%3CAddress%3E%3CAddressLine1%3EJefferson%20Summit%3C%2FAddressLine1%3E%3CAddressLine2%2F%3E%3CAddressLine3%2F%3E%3CTownOrCity%2F%3E%3CCountyOrState%2F%3E%3CProvinceOrRegion%2F%3E%3CPostOrZipCode%2F%3E%3CCountry%2F%3E%3C%2FAddress%3E%3C%2FDelivery%3E%3CItem%3E%3Cuin%3EBLL01016905070%3C%2Fuin%3E%3CtitleLevel%2F%3E%3CitemLevel%2F%3E%3CitemOfInterestLevel%2F%3E%3C%2FItem%3E%3CService%3E%3Cservice%3E1%3C%2Fservice%3E%3Cformat%3E4%3C%2Fformat%3E%3Cspeed%3E2%3C%2Fspeed%3E%3Cquality%3E1%3C%2Fquality%3E%3Cquantity%3E1%3C%2Fquantity%3E%3C%2FService%3E%3C%2FNewOrderRequest%3E&request_time=1424880494&signature_method=HMAC-SHA1",
    "_authentication_header parameter string, with body"
);

is(
    $api_obj->_authentication_header(
        {
            method => "POST",
            uri    => URI->new($api_obj->{api_url} . '/api/orders'),
            return => "request_string",
            nonce  => "rwXSiJmR2bJCZpK%2F",
            time   => "1427290955000",
            request_body => "<NewOrderRequest><type>A</type><requestor>Tommy Peters</requestor><customerReference>19</customerReference><Delivery><email/><Address><AddressLine1>Jefferson Summit</AddressLine1><AddressLine2/><AddressLine3/><TownOrCity/><CountyOrState/><ProvinceOrRegion/><PostOrZipCode/><Country/></Address></Delivery><Item><uin>BLL01016905070</uin><titleLevel/><itemLevel/><itemOfInterestLevel/></Item><Service><service>1</service><format>4</format><speed>2</speed><quality>1</quality><quantity>1</quantity></Service></NewOrderRequest>",
        }
    ),
    "POST&%2Fapi%2Forders&api_application%3DBLAPI8IJdN%26api_key%3D73-0013%26nonce%3DrwXSiJmR2bJCZpK%252F%26override_encoding_method%3Don%26request%3D%253CNewOrderRequest%253E%253Ctype%253EA%253C%252Ftype%253E%253Crequestor%253ETommy%2520Peters%253C%252Frequestor%253E%253CcustomerReference%253E19%253C%252FcustomerReference%253E%253CDelivery%253E%253Cemail%252F%253E%253CAddress%253E%253CAddressLine1%253EJefferson%2520Summit%253C%252FAddressLine1%253E%253CAddressLine2%252F%253E%253CAddressLine3%252F%253E%253CTownOrCity%252F%253E%253CCountyOrState%252F%253E%253CProvinceOrRegion%252F%253E%253CPostOrZipCode%252F%253E%253CCountry%252F%253E%253C%252FAddress%253E%253C%252FDelivery%253E%253CItem%253E%253Cuin%253EBLL01016905070%253C%252Fuin%253E%253CtitleLevel%252F%253E%253CitemLevel%252F%253E%253CitemOfInterestLevel%252F%253E%253C%252FItem%253E%253CService%253E%253Cservice%253E1%253C%252Fservice%253E%253Cformat%253E4%253C%252Fformat%253E%253Cspeed%253E2%253C%252Fspeed%253E%253Cquality%253E1%253C%252Fquality%253E%253Cquantity%253E1%253C%252Fquantity%253E%253C%252FService%253E%253C%252FNewOrderRequest%253E%26request_time%3D1427290955000%26signature_method%3DHMAC-SHA1",
    "_authentication_header request string, with body"
);

is(
    $api_obj->_authentication_header(
        {
            method => "POST",
            uri    => URI->new($api_obj->{api_url} . '/api/orders'),
            return => "authorisation_string",
            nonce  => "dgkjzPxUElpGmWhQ",
            time   => "1424880494",
            request_body => "<NewOrderRequest><type>A</type><requestor>Tommy Peters</requestor><customerReference>19</customerReference><Delivery><email/><Address><AddressLine1>Jefferson Summit</AddressLine1><AddressLine2/><AddressLine3/><TownOrCity/><CountyOrState/><ProvinceOrRegion/><PostOrZipCode/><Country/></Address></Delivery><Item><uin>BLL01016905070</uin><titleLevel/><itemLevel/><itemOfInterestLevel/></Item><Service><service>1</service><format>4</format><speed>2</speed><quality>1</quality><quantity>1</quantity></Service></NewOrderRequest>"
        }
    ),
    "SirvYrr6i+Z+P/Jc/4i+sWsbTPQ=",
    "_authentication_header authorisation string, with body"
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

# Delete request authorisation.
my $order_ref = "60010498-001";
is(
    $api_obj->_authentication_header(
        {
            method     => "DELETE",
            uri        => URI->new($api_obj->{api_url} . "/api/orders/$order_ref"),
            return     => "request_string",
            nonce      => "cAR5d2jDiTX6spi2",
            time       => "1427374322000",
            additional => { id => $order_ref },
        }
    ),
    "DELETE&%2Fapi%2Forders%2F60010498-001&api_application%3DBLAPI8IJdN%26api_key%3D73-0013%26id%3D60010498-001%26nonce%3DcAR5d2jDiTX6spi2%26override_encoding_method%3Don%26request_time%3D1427374322000%26signature_method%3DHMAC-SHA1",
    "_authentication_header request string, DELETE order"
);

# With Propagated Config
my ( $api_key, $api_key_auth, $api_application, $api_application_auth )
    = qw( 1234 test 5678 tset );

$api_obj = $class->new(
    {
        api_key              => $api_key,
        api_key_auth         => $api_key_auth,
        api_application      => $api_application,
        api_application_auth => $api_application_auth
    }
);

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
    join(
        "&",
        "api_application=" . $api_application,
        "api_key=" . $api_key,
        "nonce=dgkjzPxUElpGmWhQ",
        "override_encoding_method=on",
        "request_time=1424880494",
        "signature_method=HMAC-SHA1",
    ),
    "_authentication_header, propagated input, parameter string"
);

done_testing;
