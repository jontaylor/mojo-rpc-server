package MojoRPC::Parameters;
use Mojo::Base -base;
use Class::Method::Delegate;
use MojoRPC::Parameters::JSON;
use MojoRPC::Parameters::SIMPLE;
use MojoRPC::MethodCall;
use Carp qw( carp croak );

has [qw( parameter_type parameters )];

delegate methods => [ 'decode' ], to => sub { shift->parser };

sub parse {
  my $self = shift;
  my @parsed_parameters = $self->decode();
  my @chain;

  #The first thing in needs to be a method
  my $first_method = shift(@parsed_parameters);
  croak "Not a method" unless my $method_obj = MojoRPC::MethodCall->parse_method($first_method);
  push @chain, $method_obj;

  foreach my $param(@parsed_parameters) {
    if( my $new_obj = MojoRPC::MethodCall->parse_method($param) ) { 
      $method_obj = $new_obj;
      push @chain, $method_obj; 
    }
    else {
      $method_obj->add_parameter($param);
    }
  }

  return \@chain;
}

sub parser {
  my $self = shift;

  if(lc($self->parameter_type) eq "json") { return MojoRPC::Parameters::JSON->new() }
  if(lc($self->parameter_type) eq "simple") { return MojoRPC::Parameters::Simple->new() }
}

sub delegated_by {
  my $self = shift;
  $self->{delegated_by} = shift if(@_);
  return $self->{delegated_by};
}



1;