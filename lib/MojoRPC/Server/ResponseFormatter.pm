package MojoRPC::Server::ResponseFormatter;
use Mojo::Base -base;
use Scalar::Util qw( blessed );

has [qw( method_return_value  )];

sub json {
  my $self = shift;

  my $response_hash = {};

  #Hack for array of 1 item
  if(
    ref($self->method_return_value) eq "ARRAY" &&
    scalar(@{$self->method_return_value}) == 1
  ) {
    $self->method_return_value( $self->method_return_value->[0] );
  }

  if(blessed $self->method_return_value) {
    my $id = $self->method_return_value->can('id') ? $self->method_return_value->id() : $self->method_return_value->{id};
    $response_hash->{id} = $id if $id;
    $response_hash->{class} = ref($self->method_return_value);
    $response_hash->{data} = $self->method_return_value->TO_JSON;
  }
  else {
     $response_hash->{data} = $self->method_return_value;
  }   

  return $response_hash;
}

1;