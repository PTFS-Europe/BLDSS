package BLDSS::Config;
use strict;
use warnings;


sub new {
    my $class = shift;

    my $self = {
        customer_account_id => q{1151321}, #API Key
    };

    bless $self, $class;
    return $self;
}

sub customer_account_id {
    my $self = shift;
    return $self->{customer_account_id};
}

1;
