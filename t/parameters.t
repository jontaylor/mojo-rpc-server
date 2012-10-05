use Mojo::Base -strict;

use Test::More ;
use Test::Mojo;
use Data::Dumper;

my $t = Test::Mojo->new('MojoRPC::Server');

BEGIN { 
  use_ok('MojoRPC::Server::Parameters'); 
  use_ok('MojoRPC::Server::MethodCall');
};


my $json_params = '["$->some_method",["awesome","cool"],{"jump":"spin","roll":"duck"},{"jump":"another_jump"}]';
my $simple_params = '$->some_method/1=awesome&2=cool/jump=spin&roll=duck/jump=another_jump';
my @expected_result = ( [MojoRPC::Server::MethodCall->new({
  wants => '$',
  method_name => 'some_method',
  call_type => '->',
  parameters => [
                  [
                    'awesome',
                    'cool'
                  ],
                  {
                    'jump' => 'spin',
                    'roll' => 'duck'
                  },
                  {
                    'jump' => 'another_jump'
                  }
                ],
})]);

#Test constructor
my $json_parameter_object = new_ok("MojoRPC::Server::Parameters" => [ parameter_type => 'json', parameters => $json_params ]);
my $simple_parameter_object = new_ok("MojoRPC::Server::Parameters" => [ parameter_type => 'simple', parameters => $simple_params ]);

my @json_result =  $json_parameter_object->parse();
my @simple_result = $simple_parameter_object->parse();

is( Dumper(\@simple_result), Dumper (\@expected_result));
is( Dumper(\@json_result), Dumper (\@expected_result));

done_testing();