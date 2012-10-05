package MojoRPC::Parameters::Simple;
use Mojo::Base 'MojoRPC::Parameters';

sub decode {
  my $self = shift;

  my @params = split('/', $self->delegated_by->parameters);
  @params = map { $self->parse_parameter($_) } @params;

  return @params;
}

sub parse_parameter {
  my $self = shift;
  my $parameter_string = shift;

  my @params = split('&', $parameter_string);

  my @result;
  my $type = "array";

  foreach my $param (@params) {
    if($param =~ /=/) {
      my @parts = split('=', $param);
      push @result, [ $parts[0], $parts[1] ];
      if($parts[0] !~ /\d+/) {
        $type = "hash";
      }
    }
    else {
      push @result, $param;
    }
  }

  if(@result == 1 && !ref($result[0]) ) { return $result[0] }
  my $result_ref = $type eq "array" ? [] : {};

  foreach my $element(@result) {
    if($type eq "array") {
      $result_ref->[$element->[0]-1] = $element->[1];
    }
    else {
      $result_ref->{$element->[0]} = $element->[1];
    }
  }

  return $result_ref;
}

1;