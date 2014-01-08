package MojoRPC::Server::ResponseFormatter::Raw;
use Mojo::Base 'MojoRPC::Server::ResponseFormatter';

sub render {
	my $self = shift;
	
	warn "Responding with Raw data";
	$self->controller->res->headers->content_type('application/octet-stream');
	$self->controller->render(data => $self->method_return_value);
}

1;