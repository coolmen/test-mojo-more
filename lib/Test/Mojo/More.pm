package Test::Mojo::More;

use Mojo::Base 'Test::Mojo';

use Mojolicious::Sessions;
use Mojo::Util qw(b64_decode b64_encode);
use Mojo::JSON;
use Mojo::JSON::Pointer;

use Mojolicious::Controller;
use Mojo::Message::Request;

=head1 NAME

Test::Mojo::More - Test::Mojo and More.

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.001_000;


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Test::Mojo::More;

    my $foo = Test::Mojo::More->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 C<flash_is>

=cut

sub flash_is {
	my ($self, $key, $value, $desc) = @_;
	my ( $flash, $path ) = $self->_prepare_key($key); 
	$flash = $self->_flash($flash);
	$desc ||= "exact match for flash '$key'";
	return $self->_test(
		'is_deeply',
		Mojo::JSON::Pointer->new->get( $flash, $path ? "/$path" : "/" ),
		$value,
		$desc
	);
}

sub flash_isnt {
	my ($self, $key, $value, $desc) = @_;
	my ( $flash, $path ) = $self->_prepare_key($key); 
	$flash = $self->_flash($flash);
	$desc ||= "exact match for flash '$key'";
	return $self->_test(
		'is_deeply',
		Mojo::JSON::Pointer->new->get( $flash, $path ? "/$path" : "/" ),
		$value,
		$desc
	);
}

sub flash_has {
	my ($self, $key, $value, $desc) = @_;
	my ( $flash, $path ) = $self->_prepare_key($key); 
	$flash = $self->_flash($flash);
	$desc ||= "flash has value for JSON Pointer \"$key\"";
	return $self->_test(
		'ok',
		!!Mojo::JSON::Pointer->new->get( $flash, $path ? "/$path" : "/" ),
		$desc
	);
}

sub flash_hasnt {
	my ($self, $key, $value, $desc) = @_;
	my ( $flash, $path ) = $self->_prepare_key($key); 
	$flash = $self->_flash($flash);
	$desc ||= "flash has no value for JSON Pointer \"$key\"";
	return $self->_test(
		'ok',
		!Mojo::JSON::Pointer->new->get( $flash, $path ? "/$path" : "/" ),
		$desc
	);	
}

sub _prepare_key {
	shift;
	return ( '', '' ) unless @_;
	my ( undef, $flash, $path ) = split '\/', +shift, 3;
	( $flash, $path )
}

sub _session {
	shift->_controller->session
}

sub _flash {
	return $_[0]->_controller->flash( $_[1] ) if @_ == 2;
	{}
}


sub _controller {
	my $self = shift;

	# Build res cookies
	my $req = new Mojo::Message::Request;
	$req->cookies( join "; ", map{ $_->name ."=". $_->value } @{$self->tx->res->cookies} );

	# Make session
	my $c = Mojolicious::Controller->new;
	$c->tx->req( $req );
	$self->app->handler( $c );
	$self->app->sessions->load( $c );

	$c;
}


=head1 AUTHOR

coolmen, C<< <coolmen78 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-mojo-more at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Mojo-More>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Mojo::More


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Mojo-More>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-Mojo-More>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-Mojo-More>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-Mojo-More/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 coolmen.

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.


=cut

1; # End of Test::Mojo::More

