#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'BLDSS' ) || print "Bail out!\n";
}

diag( "Testing BLDSS $BLDSS::VERSION, Perl $], $^X" );
