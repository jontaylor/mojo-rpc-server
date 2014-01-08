package MojoRPC::Server;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Authentication;
use MIME::Base64;
use MojoRPC::Server::Whitelist;

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->_set_defaults();
  $self->_load_config();
  $self->_load_apikeys();
  $self->_load_routing();
  $self->_load_whitelist();
  $self->plugin('ValidateTiny');
  $self->_add_paths_to_inc();
  $self->_support_gzip();
}

#Have a reasonable go at converting ANY blessed reference to a json compatible hash
#Might remove this method as its dirty and its specific to modules you might not be using
sub UNIVERSAL::TO_JSON {
  my $self = shift;

  if($self->can('get_columns')) {
    return {$self->get_columns()}; #Dbix::Class
  }
  if($self->can('summary_hash')) {
    return $self->summary_hash(); #some other DB ORM
  }

  return { %$self };
}

sub _support_gzip {
  my $self = shift;

  $self->hook(after_render => sub {
    my ($c, $output, $format) = @_;

    # Check if "gzip => 1" has been set in the stash
    return unless $self->config->{gzip};

    eval { require IO::Compress::Gzip; IO::Compress::Gzip->import(); 1 };
    if($@) {
      warn "gzip not available";
      return;
    }

    # Check if user agent accepts GZip compression
    return unless ($c->req->headers->accept_encoding // '') =~ /gzip/i;
    $c->res->headers->append(Vary => 'Accept-Encoding');

    # Compress content with GZip
    $c->res->headers->content_encoding('gzip');
    IO::Compress::Gzip::gzip( $output, \my $compressed);
    $$output = $compressed;
  });

}

sub _set_defaults {
  my $self = shift;

  # Increase limit to 1GB
  $ENV{MOJO_MAX_MESSAGE_SIZE} = 1073741824;
  $self->types->type(json => 'application/json; charset=utf-8');

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
    my $user = (split(':', $request_api_key))[0];

    $app->stash({role => $user});
  });
}

sub _load_routing {
  my $self = shift;
  my $r = $self->routes;

  $r->namespaces(['MojoRPC::Server::Controller']);
  $r->route('/call/:parameter_type/:class/:params', params => qr/.*/)->via('GET')->to(controller => 'Call', action => 'call', params => undef);
  $r->route('/call/:parameter_type/:class/')->via('POST')->to(controller => 'Call', action => 'call');

}

sub _add_paths_to_inc {
  my $self = shift;

  foreach my $lib(@{$self->config->{libs}}) {
    unshift @INC, @{$lib->{paths}};
  }
  foreach my $lib(@{$self->config->{libs}}) {
    if($lib->{requires}) {
      foreach my $module (@{$lib->{requires}}) {
        eval "require $module" or die "$module could not be required " . $@;
      }
    }
  }

}

sub _load_whitelist {
  my $self = shift;

  MojoRPC::Server::Whitelist->new->add($self->config->{whitelist});
}

1;