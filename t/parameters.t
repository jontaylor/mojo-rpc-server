use Mojo::Base -strict;

use Test::More ;
use Test::Mojo;
use Data::Dumper;

my $t = Test::Mojo->new('MojoRPC');

BEGIN { use_ok('MojoRPC::Controller::Call') };


my $test_json_query = '["eric",["awesome","cool"],{"jump":"spin","roll":"duck"},{"jump":"another_jump"}]';
my @expected_json_result = ( 'eric', ['awesome', 'cool'], { jump => 'spin', roll => 'duck' }, { jump => 'another_jump' } );
my $json_parser = MojoRPC::Parameters->new(parameters =>$test_json_query, parameter_type => 'json'  );

my @json_result = $json_parser->decode($test_json_query);
is( Dumper(\@json_result), Dumper (\@expected_json_result));

my $test_simple_query = 'eric/1=awesome&2=cool/jump=spin&roll=duck/jump=another_jump';
my @expected_simple_result = ( 'eric', ['awesome', 'cool'], { jump => 'spin', roll => 'duck' }, { jump => 'another_jump' } );
my $simple_parser = MojoRPC::Parameters->new(parameters =>$test_json_query, parameter_type => 'simple'  );

my @simple_result = $simple_parser->decode($test_simple_query);
is( Dumper(\@simple_result), Dumper (\@expected_simple_result));


done_testing();