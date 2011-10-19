#!/usr/bin/perl

#
# Example from Etienne Lawlor at https://groups.google.com/forum/#!msg/yelp-developer-support/Bm4WQET5ios/_x2KiQqK9QMJ
#

use LWP::UserAgent;
use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0;
use HTTP::Request::Common;
my $ua = LWP::UserAgent->new;

sub consumer_key { 'insert consumer key here' }
sub consumer_secret { 'insert consumer secret here' }
sub access_token { 'insert access token here' }
sub access_token_secret { 'insert access token secret here' }

sub user_url { 'http://api.yelp.com/v2/search?term=food&location=San+Francisco' }

my $request =
        Net::OAuth->request('protected resource')->new(
          consumer_key => consumer_key(),
          consumer_secret => consumer_secret(),
          token => access_token(),
          token_secret => access_token_secret(),
          request_url => user_url(),
          request_method => 'GET',
          signature_method => 'HMAC-SHA1',
          timestamp => time,
          nonce => nonce(),
        );

$request->sign;

print $request->to_url."\n";

my $res = $ua->request(GET $request->to_url);
print $res->as_string;
if ($res->is_success) {
  print "Success\n";
} else {
  die "Something went wrong";
}

sub nonce {
  my @a = ('A'..'Z', 'a'..'z', 0..9);
  my $nonce = '';
  for(0..31) {
    $nonce .= $a[rand(scalar(@a))];
  }

  $nonce;
}