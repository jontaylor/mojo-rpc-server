package MojoRPC::Request;
use Mojo::Base -base;
use Scalar::Util;

has [qw(db method request_type class )];

our $whitelist;

my $valid_requests = {
  'acc4billing::locations' => {
    find_by_postcode => 'scalar',
    find_by_postcode_nospace => 'scalar',
    new => 'scalar',
    search => 'scalar',
    '->new' => 'scalar',
    '->find_by_primary_key' => 'scalar'        
  },

};

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
    return ref($class);
  }
  return $class;
}

sub valid_class {
  my $self = shift;
  $self->whitelist->{$self->class_name};
}

sub valid_method {
  my $self = shift;

  $self->whitelist->{$self->class_name}->{$self->method};
}

sub wants {
  my $self = shift;
  return $valid_requests->{$self->db}->{$self->class}->{methods}->{$self->method};
}