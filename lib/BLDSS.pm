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

sub new {
    my $class = shift;
    my $self  = {
        api_url => 'http://apitest.bldss.bl.uk',
        ua      => LWP::UserAgent->new,
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
}

sub _request {
    my ( $self, $method, $url ) = @_;
    if ( $self->{error} ) {    # clear an existing error
        delete $self->{error};
    }

    my $req = HTTP::Request->new( $method => $url );

    # If auth add as header
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

