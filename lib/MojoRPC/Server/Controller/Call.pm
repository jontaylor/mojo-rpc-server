package MojoRPC::Server::Controller::Call;
use Mojo::Base 'Mojolicious::Controller';
use Class::Method::Modifiers;
use Scalar::Util qw(blessed);
use MojoRPC::Server::Parameters;
use MojoRPC::Server::ResponseFormatter;
use MojoRPC::Server::MethodChain;
use Time::HiRes qw(alarm);
use Data::Dumper;
use URI::Escape;

around ['call'] => sub { MojoRPC::Server::Controller::Call::validate_params(@_) };

sub call {
  my $self = shift;
  my $parameter_type = $self->param('parameter_type');
  my $parameters = $self->param('params');  
  my $class = $self->param('class');

  if($self->req->method eq "GET") {
    #$parameters = uri_unescape($parameters); - Test by James demonstrates that this isn't required
  }

  if($self->app->mojo_mode eq "development") {
    print Dumper "Request Type is " . $self->req->method;
    print Dumper "Class: $class";
    print Dumper "Parameters (first 100 chars): " . substr($parameters, 0, 100);
    print Dumper "Requested timeout: " . $self->req->headers->header("RPC-Timeout") || "Not specified";
  }

  my $parameter_parser = MojoRPC::Server::Parameters->new({parameter_type => $parameter_type, parameters => $parameters});
  my $method_chain = MojoRPC::Server::MethodChain->new({class => $class, methods => $parameter_parser->parse()});

  my $result;
  eval {
    $result = $method_chain->result();
  };
  if($@) {
    $self->render_text_exception($@) and return;
  }

  my $response_formatter = MojoRPC::Server::ResponseFormatter->new({ method_return_value => $result });

  #Try and prevent the server from locking up for bad objects that self reference
  eval {
    local $SIG{ ALRM } = sub { die "Timed out in recursive JSON call" };
    alarm $self->req->headers->header("RPC-Timeout") || 10; #We aren't a websocket/comet server so don't keep us blocked for more than 5 seconds
    my $json = $response_formatter->json;
    $self->render(json => $json);
    alarm 0;
  };
  if($@) {
    alarm 0;
    if($@ eq "Timed out in recursive JSON call") {
      #Time out
      $self->render_text_exception($@) and return;
    }
    else {
      #Died for some other reason
    }
    $self->render_text_exception($@);  
  }
  
}

sub validate_params {
  my $next = shift;
  my $self = shift;

  my $validation_rules = [
     [qw/class method/] => Validate::Tiny::is_required(),   
     class          => sub { eval "require ". $self->param('class') ? undef : "Class: ". $self->param('class') ." not found" },
  ];

  unless( $self->do_validation($validation_rules) ) {
    $self->render( status => 500, text =>$self->validator_any_error);
    return undef;
  }
  return $self->$next(@_);
}

sub render_text_exception {
  my $self = shift;
  my $error = shift;
  my @stacktrace;

  if(blessed $error && $error->can('frames')) {
    @stacktrace = map { $_->[1] . ":" . $_->[2] } @{$error->frames};
    $self->render( status => 500, text => $error->to_string . "\n" . join("\n", @stacktrace ) ."\n"); 
  }
  else {
    $self->render( status => 500, text => $error ."\n"); 
  }

  
}

1;