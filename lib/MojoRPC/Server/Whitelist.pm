package MojoRPC::Server::Whitelist;
use Mojo::Base -base;
use Hash::Merge qw( merge );
use Carp qw( croak );

our $instance;

has 'whitelist' => sub { return {} };

sub new {
  my $class = shift;
  return $instance if $instance;

  $instance = $class->SUPER::new(@_);
  return $instance;
}

sub add {
  my $self = shift;
  my $whitelist_hashref = shift;

  croak "Parameter to merge should be a hashref" unless ref($whitelist_hashref) eq "HASH";

  $self->whitelist( merge($self->whitelist, $whitelist_hashref)  );
}

sub class_listed {
  my $self = shift;
  my $class_name = shift;

  return 1 if ref($self->whitelist()->{$class_name}) eq "HASH";
  return 0;
}

sub class_and_method_allowed {
  my $self = shift;
  my $class_name = shift;
  my $method_name = shift;

  return 0 unless $self->class_listed($class_name);

  return 0 unless $self->whitelist->{$class_name}->{$method_name};

  return 1;
}




1;