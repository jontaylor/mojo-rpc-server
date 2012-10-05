package MojoRPC::MethodCall;
use Mojo::Base -base;
use Scalar::Util qw(blessed);

has [qw( method_name parameters call_type wants )];

sub parse_method {
  my $class = shift;
  my $thing = shift;
  $thing =~ /^(@|\$)(::|->)(.+)/;
  my $attributes = {
    wants => $1,
    call_type => $2,
    method_name => $3,
    parameters => []
  };

  return undef unless $attributes->{method_name};
  return $class->new($attributes);
}

sub add_parameter {
  my $self = shift;
  my $parameter = shift;

  push @{$self->parameters()}, $parameter;
}

sub call_on {
  my $self = shift;
  my $object_or_class = shift;

  if($self->is_a_class_method) {
    $self->call_on_class($object_or_class);
  }
  else {
    $self->call_on_object($object_or_class);
  }
}

sub expects_array {
  my $self = shift;

  return $self->wants eq "@";
}

sub is_a_class_method {
  my $self = shift;
  return $self->call_type eq "::"
}

sub call_on_class {
  my $self = shift;
  my $class = shift;
  my $return_value;
  if(blessed $class) { $class = ref($class) }

  my $method_call = $class."::".$method;

  no strict 'refs';
  if($self->expects_array) {
    $return_value = [ &$method_call (@parameters) ];
  }
  else {
    $return_value = &$method_call (@parameters);
  }    
  use strict 'refs';  

  return $return_value;
}

sub call_on_object {
  my $self = shift;
  my $object = shift;
  my $return_value;
  my $method = $self->method();

  if($self->expects_array) {
    $return_value = [ $object->$method (@parameters) ];
  }
  else {
    $return_value = $object->$method (@parameters);
  }

  return $return_value;
}

sub check_permissions {
  my $self = shift;
  my $object_or_class = shift;

  if(my $method_ref = $object_or_class->can('rpc_server_rights')) {
    $object_or_class->$method_ref($self->method(), $self->role());
  }


}

1;