package MojoRPC::Parameters::JSON;
use Mojo::Base 'MojoRPC::Parameters';
use JSON::XS;

sub decode {
  my $self = shift;
  my $json = JSON::XS->new->allow_nonref();
  return @{$json->decode($self->delegated_by->parameters)};
}

1;