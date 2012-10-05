use Mojo::Base -strict;

use Test::More ;
use Test::Mojo;
use Data::Dumper;

my $t = Test::Mojo->new('MojoRPC');

BEGIN { use_ok('MojoRPC::Controller::Call') };

done_testing();