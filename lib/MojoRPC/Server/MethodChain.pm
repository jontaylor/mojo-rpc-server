package MojoRPC::Server::MethodChain;
use Mojo::Base -base;

has [qw( class methods )];

sub result {
  my $self = shift;

  return $self->call_chain();
}

sub call_chain {
  my $self = shift;
  my $return_value = $self->class();
  my $methods = $self->methods();

  foreach my $method_call(@$methods) {
    $return_value = $method_call->call_on($return_value);
  }

  return $return_value;
}

1;