use Mojo::Base -strict;

use Test::More ;
use Data::Dumper;

BEGIN { 
  use_ok('MojoRPC::Server::Whitelist'); 
};

my $whitelist = new_ok('MojoRPC::Server::Whitelist');

is(ref($whitelist->whitelist), 'HASH');

my $datetime_whitelist = {
  'DateTime' => {
    'now' => 1,

  }
};

$whitelist->add($datetime_whitelist);


is($whitelist->class_listed('not_listed'), 0);
is($whitelist->class_listed('DateTime'), 1);

is($whitelist->class_and_method_allowed('No', "No"), 0);
is($whitelist->class_and_method_allowed('DateTime', "No"), 0);
is($whitelist->class_and_method_allowed('DateTime', "NOW"), 0);
is($whitelist->class_and_method_allowed('DateTime', "now"), 1);




done_testing();