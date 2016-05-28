package Mojolicious::Plugin::LogDispatch;

use strict;
use warnings;
use Mojo::Base 'Mojolicious::Plugin';

use Log::Dispatch;

our $VERSION = '0.01';

sub register {
    my ( $self, $app, $conf ) = @_;

    # Adding "log" helper
    $app->helper(
        log => sub {
            my ( $self, $level, @msgs ) = @_;

            # Check log level
            $level = lc $level;
            return $self unless $level && $self->is_level($level);

            $self->handle->log( 'level' => $level, 'message' => @msgs );
            return $self;
        }
    );
}

#some methods from Log::Dispatch
sub add {
    my $self = shift;
    my $l    = $self->handle->add(@_);

    #remove default log object that log to STDERR?
    $self->remove('_default_log_obj') if $self->remove_default_log_obj;
    return $l;
}

sub remove { return shift->handle->remove(@_) }

sub fatal     { shift->log( 'emergency', @_ ) }
sub emergency { shift->log( 'emergency', @_ ) }
sub alert     { shift->log( 'alert',     @_ ) }
sub critical  { shift->log( 'critical',  @_ ) }
sub warning   { shift->log( 'warning',   @_ ) }
sub warn      { shift->log( 'warning',   @_ ) }
sub notice    { shift->log( 'notice',    @_ ) }

#short alias syslog style
sub err   { shift->log( 'error',     @_ ) }
sub crit  { shift->log( 'critical',  @_ ) }
sub emerg { shift->log( 'emergency', @_ ) }

sub is_level {
    my ( $self, $level ) = @_;
    return 0 unless $level;
    $level = lc $level;
    return $self->would_log($level);
}

sub is_fatal     { shift->is_level('emergency') }
sub is_emergency { shift->is_level('emergency') }
sub is_alert     { shift->is_level('alert') }
sub is_critical  { shift->is_level('critical') }
sub is_warning   { shift->is_level('warning') }
sub is_warn      { shift->is_level('warning') }
sub is_notice    { shift->is_level('notice') }
sub is_err       { shift->is_level('error') }
sub is_crit      { shift->is_level('critical') }
sub is_emerg     { shift->is_level('emergency') }

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::LogDispatch - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('LogDispatch');

  # Mojolicious::Lite
  plugin 'LogDispatch';

=head1 DESCRIPTION

L<Mojolicious::Plugin::LogDispatch> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::LogDispatch> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

, , 

=head1 SEE ALSO

=over

=item L<Mojolicious>

=item L<Mojolicious::Guides>

=item L<http://mojolicio.us>.

=item L<Log::Dispatch>

=item L<MojoX::Log::Dispatch>

=back

=head1 AUTHOR

Jonas B. Nielsen, (jonasbn) - C<< <jonasbn@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Mojolicious-Plugin-LogDispatch is (C) by Jonas B. Nielsen, (jonasbn) 2016

Mojolicious-Plugin-LogDispatch is released under the Artistic License 2.0

=cut

=cut
