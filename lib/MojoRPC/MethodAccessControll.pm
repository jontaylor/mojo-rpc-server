package MojoRPC::MethodAccessControll;
use Mojo::Base -base;
use Scalar::Util qw(blessed);

has [qw( method class )];

our $whitelist;

sub set_whitelist {
  $whitelist = shift;
}

sub whitelist {
  return $whitelist;
}

sub valid {
  my $self = shift;
  return $self->valid_class && $self->valid_method;
}

sub class_name {
  my $self = shift;
  if(blessed $self->class) {
    return ref($self->class);
  }
  return $self->class;
}

sub valid_class {
  my $self = shift;
  $self->whitelist->{$self->class_name};
}

sub valid_method {
  my $self = shift;

  $self->whitelist->{$self->class_name}->{$self->method};
}

1;