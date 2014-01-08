package MojoRPC::Server::ResponseFormatter;
use Mojo::Base -base;
use Scalar::Util qw( blessed );

use MojoRPC::Server::ResponseFormatter::JSON;
use MojoRPC::Server::ResponseFormatter::Raw;

has [qw( method_return_value controller )];

sub factory {
  my $class = shift;
  my $options = shift;

  return MojoRPC::Server::ResponseFormatter::JSON->new($options) if ref($options->{method_return_value}); #Refs always respond with JSON
  
  return MojoRPC::Server::ResponseFormatter::Raw->new($options) if ($options->{controller}->req->headers->accept // '') =~ /application\/octet-stream/i;

  return MojoRPC::Server::ResponseFormatter::JSON->new($options); #Default
}



1;