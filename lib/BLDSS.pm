package BLDSS;

use strict;
use warnings;

=head1 NAME

BLDSS - Client Interface to BLDSS API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Object to handle interaction with BLDSS via the api

    use BLDSS;

    my $foo = BLDSS->new();
    my $xml = $foo->search('Smith OR Jones AND ( Literature OR Philosophy )');
    if (!$xml) {
      carp $foo->error;
    }
    ...

=head1 SUBROUTINES/METHODS

=head2 TBD

=cut

use LWP::UserAgent;
use URI;
use XML::LibXML;

sub new {
    my $class = shift;
    my $self  = {
        api_url     => 'http://apitest.bldss.bl.uk',
        ua          => LWP::UserAgent->new,
        application => 'KohaTestILL',
    };

    # authentication header will require
    # api_application
    # api_key
    # request_time = time(); recalc per request
    # nonce
    # signature_method=HMAC-SHA1
    # authorisation
    bless $self, $class;
    return $self;
}

sub search {
    my ( $self, $search_str, $opt ) = @_;

    # search string can use AND OR and brackets
    my $url_string = $self->{api_url} . "/api/search/$search_str";
    my $url        = URI->new($url_string);
    if ( ref $opt eq 'HASH' ) {
        my @key_pairs;
        if ( exists $opt->{max_results} ) {
            push @key_pairs, 'SearchRequest.maxResults', $opt->{max_results};
        }
        if ( exists $opt->{start_rec} ) {
            push @key_pairs, 'SearchRequest.start', $opt->{start_rec};
        }
        if ( $opt->{full} ) {
            push @key_pairs, 'SearchRequest.fullDetails', 'true';
        }
        if ( exists $opt->{isbn} ) {
            push @key_pairs, 'SearchRequest.Advanced.isbn', $opt->{isbn};
        }
        if ( exists $opt->{issn} ) {
            push @key_pairs, 'SearchRequest.Advanced.issn', $opt->{issn};
        }
        if ( exists $opt->{title} ) {
            push @key_pairs, 'SearchRequest.Advanced.title', $opt->{title};
        }
        if ( exists $opt->{author} ) {
            push @key_pairs, 'SearchRequest.Advanced.author', $opt->{author};
        }
        if ( exists $opt->{type} ) {
            push @key_pairs, 'SearchRequest.Advanced.type', $opt->{type};
        }
        if ( exists $opt->{general} ) {
            push @key_pairs, 'SearchRequest.Advanced.general', $opt->{general};
        }
        if (@key_pairs) {
            $url->query_form( \@key_pairs );
        }
    }
    return $self->_request( 'GET', $url );
}

sub match {
    my ( $self, $bib, $opt ) = @_;

    my $url_string = $self->{api_url} . '/api/match';
    my %bibfields  = (
        title             => 'MatchRequest.BibData.titleLevel.title',
        author            => 'MatchRequest.BibData.authorLevel.author',
        isbn              => 'MatchRequest.BibData.titleLevel.ISBN',
        issn              => 'MatchRequest.BibData.titleLevel.ISSN',
        ismn              => 'MatchRequest.BibData.titleLevel.ISMN',
        shelfmark         => 'MatchRequest.BibData.titleLevel.shelfmark',
        publisher         => 'MatchRequest.BibData.titleLevel.publisher',
        conference_venue  => 'MatchRequest.BibData.titleLevel.conferenceVenue',
        conference_date   => 'MatchRequest.BibData.titleLevel.conferenceDate',
        thesis_university => 'MatchRequest.BibData.titleLevel.thesisUniversity',
        thesis_dissertation =>
          'MatchRequest.BibData.titleLevel.thesisDissertation',
        map_scale       => 'MatchRequest.BibData.titleLevel.mapScale',
        year            => 'MatchRequest.BibData.itemLevel.year',
        volume          => 'MatchRequest.BibData.itemLevel.volume',
        part            => 'MatchRequest.BibData.itemLevel.part',
        issue           => 'MatchRequest.BibData.itemLevel.issue',
        edition         => 'MatchRequest.BibData.itemLevel.edition',
        season          => 'MatchRequest.BibData.itemLevel.season',
        month           => 'MatchRequest.BibData.itemLevel.month',
        day             => 'MatchRequest.BibData.itemLevel.day',
        special_issue   => 'MatchRequest.BibData.itemLevel.specialIssue',
        interest_title  => 'MatchRequest.BibData.itemOfInterestLevel.title',
        interest_pages  => 'MatchRequest.BibData.itemOfInterestLevel.pages',
        interest_author => 'MatchRequest.BibData.itemOfInterestLevel.author',
    );

    my $url = URI->new($url_string);
    my @key_pairs;
    my $prefix_b  = 'MatchRequest.BibData.titleLevel.';
    my $prefix_i  = 'MatchRequest.BibData.itemLevel.';
    my $prefix_ii = 'MatchRequest.BibData.itemOfInterestLevel.';
    foreach my $b ( keys %{$bib} ) {
        push @key_pairs, $bibfields{$b}, $bib->{$b};
    }
    if ($opt) {
        if ( exists $opt->{maxResults} ) {
            push @key_pairs, 'MatchRequest.maxRecords', $opt->{maxResults};
        }
    }
    foreach my $option (
        qw( includeRecordDetails includeAvailability fullDetails highMatchOnly))
    {
        if ( $opt->{$option} ) {
            push @key_pairs, "MatchRequest.$option", 'true';
        }
    }

    $url->query_form( \@key_pairs );
    return $self->_request( 'GET', $url );
}

sub availability {
    my ( $self, $uin, $opt ) = @_;
    my @param = ( 'AvailabilityRequest.uin', $uin );
    if ($opt) {
        if ( $opt->{includeprices} ) {
            push @param, 'AvailabilityRequest.includePrices', 'true';
        }
        my %item_field = (
            year          => 'AvailabilityRequest.Item.year',
            volume        => 'AvailabilityRequest.Item.volume',
            part          => 'AvailabilityRequest.Item.part',
            issue         => 'AvailabilityRequest.Item.issue',
            edition       => 'AvailabilityRequest.Item.edition',
            season        => 'AvailabilityRequest.Item.season',
            month         => 'AvailabilityRequest.Item.month',
            day           => 'AvailabilityRequest.Item.day',
            special_issue => 'AvailabilityRequest.Item.specialIssue',
        );
        foreach my $key ( keys %item_field ) {
            if ( $opt->{$key} ) {
                push @param, $item_field{$key}, $opt->{$key};

            }
        }
    }

    my $url_string = $self->{api_url} . '/api/availability';
    my $url        = URI->new($url_string);
    $url->query_form( \@param );
    return $self->_request( 'GET', $url );
}

sub approvals {
    my ( $self, $opt ) = @_;
    my @param;
    if ($opt) {
        if ( $opt->{start} ) {
            push @param, 'ApprovalsRequest.startIndex', $opt->{start};
        }
        if ( $opt->{max_records} ) {
            push @param, 'ApprovalsRequest.maxRecords', $opt->{max_records};
        }
        if ( $opt->{filter} ) {
            push @param, 'ApprovalsRequest.filter', $opt->{filter};
        }
        if ( $opt->{format} ) {
            push @param, 'ApprovalsRequest.format', $opt->{format};
        }
        if ( $opt->{speed} ) {
            push @param, 'ApprovalsRequest.speed', $opt->{speed};
        }
        if ( $opt->{order} ) {
            push @param, 'ApprovalsRequest.sortOrder', $opt->{order};
        }
    }

    my $url_string = $self->{api_url} . '/api/approvals';
    my $url        = URI->new($url_string);
    if (@param) {
        $url->query_form( \@param );
    }
    return $self->_request( 'GET', $url );
}

sub customer_preferences {
    my $self = shift;

    my $url_string = $self->{api_url} . '/api/customer';
    my $url        = URI->new($url_string);
    return $self->_request( 'GET', $url );
}

sub cancel_order {
    my ( $self, $orderline_ref ) = @_;
    my $url_string = $self->{api_url} . "/api/orders/$orderline_ref";
    my $url        = URI->new($url_string);
    return $self->_request( 'DELETE', $url );
}

sub create_order {
    my ( $self, $order_ref ) = @_;
    my $xml;    # TBD generate from order_ref
    my $url_string = $self->{api_url} . '/api/orders';
    my $url        = URI->new($url_string);
    return $self->_request( 'POST', $url, $xml );
}

sub order {
    my ( $self, $order_ref ) = @_;

    # order_ref can be orderline ref or request id
    my $url_string = $self->{api_url} . "/api/orders/$order_ref";
    my $url        = URI->new($url_string);
    return $self->_request( 'GET', $url );
}

sub orders {
    my ( $self, $selection ) = @_;

    # return multiple orders based on criteria in selection
    #
    my $url_string = $self->{api_url} . '/api/orders';
    my $url        = URI->new($url_string);
    my %map_sel    = (
        start_date  => 'OrdersRequest.startDate',
        end_date    => 'OrdersRequest.endDate',
        start_index => 'OrdersRequest.startIndex',
        max_records => 'OrdersRequest.maxRecords',
        sort_order  => 'OrdersRequest.sortOrder',
        filter      => 'ApprovalsRequest.filter',
        format      => 'ApprovalsRequest.format',
        speed       => 'ApprovalsRequest.speed',
    );
    my @param;
    if ( exists $selection->{events} ) {
        push @param, 'OrdersRequest.eventsOnly', 'true';
        delete $selection->{events};
    }

    if ( exists $selection->{orders} ) {
        push @param, 'OrdersRequest.ordersOnly', 'true';
        delete $selection->{orders};
    }
    if ( exists $selection->{requests} ) {
        push @param, 'OrdersRequest.requestsOnly', 'true';
        delete $selection->{orders};
    }
    if ( exists $selection->{open_only} ) {
        push @param, 'OrdersRequest.openOnly', 'true';
        delete $selection->{open_only};
    }
    foreach my $key ( keys %{$selection} ) {
        if ( exists $map_sel{$key} ) {
            push @param, $map_sel{$key}, $selection->{$key};
        }
    }

    $url->query_form( \@param );
    return $self->_request( 'GET', $url );
}

sub renew_loan {
    my ( $self, $orderline, $requestor ) = @_;
    my $url_string = $self->{api_url} . '/api/orders/renewLoan';
    my $url        = URI->new($url_string);

    my $doc               = XML::LibXML::Document->new();
    my $request           = $doc->createElement('RenewalRequest');
    my $orderline_element = $doc->createElement('orderline');
    $orderline_element->appendTextNode($orderline);
    $request->appendChild($orderline_element);
    if ($requestor) {
        my $element = $doc->createElement('requestor');
        $element->appendTextNode($requestor);
        $request->appendChild($element);
    }
    my $xml = $request->toString();
    return $self->_request( 'PUT', $url, $xml );
}

sub reportProblem {
    my ( $self, $param ) = @_;
    my $url_string = $self->{api_url} . '/api/orders/renewLoan';
    my $url        = URI->new($url_string);

    my $doc     = XML::LibXML::Document->new();
    my $request = $doc->createElement('ReportProblemRequest');
    foreach my $name (qw( requestId type email requestor text)) {
        my $element = $doc->createElement($name);
        $element->appendTextNode( $param->{$name} );
        $request->appendChild($element);
    }
    if ( exists $param->{phone} ) {
        my $element = $doc->createElement('phone');
        $element->appendTextNode( $param->{phone} );
        $request->appendChild($element);
    }

    my $xml = $request->toString();
    return $self->_request( 'PUT', $url, $xml );
}

sub prices {
    my ( $self, $param ) = @_;
    my $url_string = $self->{api_url} . '/api/prices';
    my $url        = URI->new($url_string);
    my @optional_param;
    foreach my $opt (qw( region service format currency )) {
        if ( exists $param->{$opt} ) {
            push @optional_param, "PricesRequest.$opt", $param->{$opt};
        }
    }
    if (@optional_param) {
        $url->query_form( \@optional_param );
    }
    return $self->_request( 'GET', $url );
}

sub reference {
    my ( $self, $reference_type ) = @_;

    #TBD perlvars top camel case ??
    my %valid_reference_calls = (
        costTypes              => 1,
        currencies             => 1,
        deliveryModifiers      => 1,
        formats                => 1,
        problemClassifications => 1,
        problemTypes           => 1,
        quality                => 1,
        services               => 1,
        speeds                 => 1,
    );
    if ( !exists $valid_reference_calls{$reference_type} ) {
        return;
    }
    my $url_string = $self->{api_url} . "/reference/$reference_type";
    my $url        = URI->new($url_string);
    return $self->_request( 'GET', $url );
}

sub rejected_requests {
    my ( $self, $options ) = @_;
    my $url_string = $self->{api_url} . '/reference/rejectedRequests';
    my $url        = URI->new($url_string);
    my @opt;
    if ( exists $options->{start} ) {
        push @opt, 'RejectedRequestsRequest.startIndex', $options->{start};
    }
    if ( exists $options->{max_records} ) {
        push @opt, 'RejectedRequestsRequest.maxRecords',
          $options->{max_records};
    }
    if (@opt) {
        $url->query_form( \@opt );
    }
    return $self->_request( 'GET', $url );
}

sub estimated_despatch_date {
    my ( $self, $options ) = @_;
    my $url_string = $self->{api_url} . '/utility/estimatedDespatch';
    my $url        = URI->new($url_string);
    my @opt;
    if ( exists $options->{availability_date} ) {
        push @opt, 'EstimatedDespatchRequest.availabilityDate',
          $options->{availability_date};
    }
    if ( exists $options->{speed} ) {
        push @opt, 'EstimatedDespatchRequest.speed', $options->{speed};
    }
    if (@opt) {
        $url->query_form( \@opt );
    }
    return $self->_request( 'GET', $url );
}

sub _request {
    my ( $self, $method, $url, $content ) = @_;
    if ( $self->{error} ) {    # clear an existing error
        delete $self->{error};
    }

    my $req = HTTP::Request->new( $method => $url );

    # If auth add as header
    if ( $self->{authentication_request} ) {
        $req->header(
            'BLDSS-API-Authentication' => $self->{authentication_request} );
    }

    # add content if specified
    if ($content) {
        $req->content($content);
    }

    my $res = $self->{ua}->request($req);
    if ( $res->is_success ) {
        return $res->content;
    }
    $self->{error} = $res->status_line;
    return;
}

sub error {
    my $self = shift;

    return $self->{error};
}

1;
__END__


=head2 Primary Operations

=over

=item Search

http://api.bldss.bl.uk/api/search - HTTP GET

=item Availability

http://api.bldss.bl.uk/api/availability - HTTP GET

=item Create Order

http://api.bldss.bl.uk/api/orders - HTTP POST

=item Match

http://api.bldss.bl.uk/api/match - HTTP GET

=back

=head2 Secondary Operations

=over

=item View Order(s)

http://api.bldss.bl.uk/api/orders - HTTP GET

=item Cancel Order

http://api.bldss.bl.uk/api/orders - HTTP DELETE

=item Renew A Loan

http://api.bldss.bl.uk/api/renewLoan - HTTP PUT

=item Report A Problem

http://api.bldss.bl.uk/api/reportProblem - HTTP PUT

=item Get Prices

http://api.bldss.bl.uk/api/prices - HTTP GET

=back

=head2 Reference Operations

=over

=item Check exchange rates

http://api.bldss.bl.uk/reference/currencies - HTTP GET

=item Document delivery format keys

http://api.bldss.bl.uk/reference/formats - HTTP GET

=item Document delivery speed keys

http://api.bldss.bl.uk/reference/speeds - HTTP GET

=item Document delivery quality keys

http://api.bldss.bl.uk/reference/quality - HTTP GET

=item Document delivery problem keys

http://api.bldss.bl.uk/reference/problemTypes - HTTP GET

=back

