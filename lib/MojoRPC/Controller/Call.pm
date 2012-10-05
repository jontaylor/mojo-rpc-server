package MojoRPC::Controller::Call;
use Mojo::Base 'Mojolicious::Controller';
use Class::Method::Modifiers;
use MojoRPC::Request;
use Scalar::Util qw(blessed);
use Data::Dumper;
use MojoRPC::Parameters;
use MojoRPC::ResponseFormatter;
use MojoRPC::MethodChain;

around ['call'] => sub { MojoRPC::Controller::Call::validate_params(@_) };

sub call {
  my $self = shift;
  my $parameter_type = $self->param('parameter_type');
  my $parameters = $self->param('params');  
  my $class = $self->param('class');

  my $parameter_parser = MojoRPC::Parameters->new({parameter_type => $parameter_type, parameters => $parameters});
  my $method_chain = MojoRPC::MethodChain->new({class => $class, methods => $parameter_parser->parse()});

  my $result;
  eval {
    $result = $method_chain->result();
  };
  if($@) {
    if($self->app->mojo_mode eq "development") {
      $self->render_400($@);
    }
    else {
      $self->render_500("Something went wrong");
    }  
  }

  my $response_formatter = MojoRPC::ResponseFormatter->new({ method_return_value => $result });
  $self->render_json($response_formatter->json);
}



sub validate_params {
  my $next = shift;
  my $self = shift;

  my $validation_rules = [
     [qw/class method/] => Validate::Tiny::is_required(),   
     class          => sub { eval "require ". $self->param('class') ? undef : "Class not found" },
  ];

  unless( $self->do_validation($validation_rules) ) {
    $self->render_500($self->validator_any_error);
    return undef;
  }
  return $self->$next(@_);
}

sub render_400 {
  my $self = shift;
  my $error = shift;
  $self->render( status => '400', text => $error ); 
}

1;