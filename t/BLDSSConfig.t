#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 3;

BEGIN { use_ok('BLDSS::Config'); }

my $class = 'BLDSS::Config';

my $conf_obj = $class->new();

isa_ok( $conf_obj, $class );

my $ret_id = $conf_obj->customer_account_id();

my $id = q{1151321};

cmp_ok( $ret_id, '==', $id, 'Correct customer account id returned' );

