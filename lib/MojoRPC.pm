package MojoRPC;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Authentication;
use MIME::Base64;

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->_load_config();
  $self->_load_apikeys();
  $self->_load_authentication();
  $self->_load_routing();
  $self->plugin('ValidateTiny');
}

#Have a reasonable go at converting ANY blessed reference to a json compatible hash
sub UNIVERSAL::TO_JSON {
  my $self = shift;

  if($self->can('get_columns')) {
    return {$self->get_columns()};
  }
  if($self->can('summary_hash')) {
    return $self->summary_hash();
  }

  return { %$self };
}


sub mojo_mode {
  my $self = shift;
  # Application Config
  return $ENV{MOJO_MODE} || 'development';
}  

sub _load_config {
  my $self = shift;
  my $config = $self->plugin('Config', {file => "config/" . $self->mojo_mode . ".conf"});
}


sub _load_apikeys {
  my $self = shift;

  $self->hook(before_dispatch => sub {
    my $app = shift;

    my $request_api_key = $app->req->headers->header('Authorization') || "";
    $request_api_key =~ s/Basic //g;
    $request_api_key = decode_base64($request_api_key);

    if( !$app->config->{apikeys}->{$request_api_key} ) {
      $app->res->headers->header('WWW-Authenticate' => 'Basic realm="Secure Area"');
      $app->render(status=>401, text => "Invalid API KEY");
    } 

  });
}

sub _load_routing {
  my $self = shift;
  my $r = $self->routes;

  $r->namespace('MojoRPC::Controller');
  $r->route('/call/:parameter_type/:class/:params', params => qr/.*/)->to(controller => 'Call', action => 'call', params => undef);
}

sub _load_authentication {
  my $self = shift;
 
  $self->plugin('authentication' => {
      'autoload_user' => 1,
      'session_key' => 'th1sISaSESSIONk3y',
      'load_user' => sub { return undef; },
      'validate_user' => sub {
        my ($app, $username, $password, $extradata) = @_; 
        
        return undef;
      },
      'current_user_fn' => 'user', # compatibility with old code
  });
}

sub _add_paths_to_inc {
  my $self = shift;

  foreach my $lib(@{$self->config->{libs}}) {
    push @INC, @{$lib->{paths}};
    if($lib->{requires}) {
      foreach my $module (@{$lib->{requires}}) {
        eval "require $module";
      }
    }
  }
}

1;