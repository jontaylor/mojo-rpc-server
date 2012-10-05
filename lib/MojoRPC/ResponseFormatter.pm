package MojoRPC::ResponseFormatter;
use Mojo::Base -base;
use Scalar::Util qw( blessed );

has [qw( method_return_value  )];

sub json {
  my $self = shift;

  my $response_hash = {};
  $response_hash->{data} = $return_value;
  if(blessed $return_value) {
    my $id = $return_value->can('id') ? $return_value->id() : $return_value->{id};
    $response_hash->{id} = $id if $id;
    $response_hash->{class} = ref($return_value);
  }

  return $response_hash;

}

1;