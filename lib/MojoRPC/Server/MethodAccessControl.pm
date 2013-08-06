package MojoRPC::Server::MethodAccessControl;
use Mojo::Base -base;
use Scalar::Util qw(blessed);

has [qw( method class )];

has whitelist => sub {
  return MojoRPC::Server::Whitelist->new();
};

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

  my $class = $self->class();

  eval "require $class" or return 0;

  $self->whitelist->class_listed($self->class);
}

sub valid_method {
  my $self = shift;

  $self->whitelist->class_and_method_allowed($self->class, $self->method);
}

1;