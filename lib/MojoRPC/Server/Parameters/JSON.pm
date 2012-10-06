package MojoRPC::Server::Parameters::JSON;
use Mojo::Base 'MojoRPC::Server::Parameters';
use JSON::XS;
use URI::Escape;

sub decode {
  my $self = shift;
  my $json = JSON::XS->new->allow_nonref();
  my @params = @{$json->decode(uri_unescape($self->delegated_by->parameters))};

  return @params;
}

1;