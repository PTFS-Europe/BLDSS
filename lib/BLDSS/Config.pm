package BLDSS::Config;
use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {
        customer_account_id => q{1151321},    #API Key
        api_application_id  => {
            key  => 'BLAPluy8my',
            auth => '3bo7y9vYjK1',
            name => 'KohaTestILL',
            id   => 25,
        },

        # BL default developer's test account
        account      => '87-0656',
        api_key_auth => 'APIDEV176',
    };

    bless $self, $class;
    return $self;
}

sub customer_account_id {
    my $self = shift;
    return $self->{customer_account_id};
}

sub api_application_id {
    my $self = shift;
    return $self->{api_application_id}->{id};
}

1;
