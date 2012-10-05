use Mojo::Base -strict;

use Test::More ;
use Test::Mojo;
use Data::Dumper;

my $t = Test::Mojo->new('MojoRPC::Server');

BEGIN { use_ok('MojoRPC::Server::Controller::Call') };

done_testing();