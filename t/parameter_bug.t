use Mojo::Base -strict;

use Test::More ;
use Test::Mojo;
use Data::Dumper;

BEGIN { 
  use_ok('MojoRPC::Server::Parameters'); 
  use_ok('MojoRPC::Server::MethodCall');
};

use URI::Escape;

my $encoded_params = '/call/json//%5B%22%24-%3Esearch%22%2C%22where%22%2C%22%28description%20LIKE%20%3F%29%20OR%20%28overridedescription%20LIKE%20%3F%29%22%2C%22vars%22%2C%5B%22%25daisy%25%22%2C%22%25daisy%25%22%5D%2C%22limit%22%2C10%2C%22order_by%22%2C%22description%22%5D';

is(uri_unescape($encoded_params), '/call/json//["$->search","where","(description LIKE ?) OR (overridedescription LIKE ?)","vars",["%daisy%","%daisy%"],"limit",10,"order_by","description"]');


done_testing();