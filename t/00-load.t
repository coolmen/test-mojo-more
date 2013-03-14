#!perl -T
use 5.10;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Test::Mojo::More' ) || print "Bail out!\n";
}

diag( "Testing Test::Mojo::More $Test::Mojo::More::VERSION, Perl $], $^X" );
