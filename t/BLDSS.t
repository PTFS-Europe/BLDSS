#!/usr/bin/perl
use strict;
use warnings;

use Test::More;

BEGIN { use_ok( 'BLDSS' ); }

my $class = 'BLDSS';

my $api_obj = $class->new();

isa_ok($api_obj, $class);

my $resp = $api_obj->simple_search('slovenia');

my $r_start = q{<?xml version="1.0" encoding="UTF-8"?><apiResponse.};
my $start_len = length $r_start;
my $string = substr $resp, 0, $start_len;

cmp_ok($string, 'cmp', $r_start, 'SimpleSearch received response'); 
done_testing();

