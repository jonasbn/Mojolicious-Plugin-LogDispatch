package Mojolicious::Plugin::LogDispatch;

use strict;
use warnings;
use Mojo::Base qw(Mojolicious::Plugin);
use base qw(Mojo::Log);

use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;

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

            # We define a default log handle until told otherwise
            $self->handle->log( 'level' => $level, 'message' => @msgs );

            return $self;
        }
    );
}

__PACKAGE__->attr(
    'handle' => sub {
        my $self = shift;
                my $dispatcher;

                if ($self->callbacks)
                {
                        
                         $dispatcher = Log::Dispatch->new(callbacks => $self->callbacks);      
                }
                else
                {
                        
                        $dispatcher = Log::Dispatch->new(@_);
                }
                 
                if ($self->path)
                {
        
                         $dispatcher->add(Log::Dispatch::File->new( 'name'      => '_default_log_obj',
                                                                            'min_level' => $self->level,
                                                                            'filename'  => $self->path,
                                                                            'mode'      => 'append' )
                                                                                                );                         
                         
                }
                else
                {
        
                        # Create a logging object that will log to STDERR by default
                        $dispatcher->add(Log::Dispatch::Screen->new(      'name'      => '_default_log_obj',
                                                                                'min_level' => $self->level,
                                                                                'stderr'    => 1 )
                                                                                                        );              
                }

                return $dispatcher;
    }
);
 
__PACKAGE__->attr('callbacks');
__PACKAGE__->attr('remove_default_log_obj' => 1);

#some methods from Log::Dispatch
sub add {
    my $self = shift;
    my $l    = $self->handle->add(@_);

    #remove default log object that log to STDERR?
    $self->remove('_default_log_obj') if $self->remove_default_log_obj;
    return $l;
}

sub dispatcher { return shift->handle }

sub log {
    my ( $self, $level, @msgs ) = @_;

    # Check log level
    $level = lc $level;
    return $self unless $level && $self->is_level($level);

    $self->handle->log( 'level' => $level, 'message' => @msgs );
    return $self;
}

sub remove         { return shift->handle->remove(@_) }
sub output         { return shift->handle->output(@_) }
sub would_log      { return shift->handle->would_log(@_) }
sub log_to         { return shift->handle->log_to(@_) }
sub level_is_valid { return shift->handle->level_is_valid(@_) }
sub log_and_die    { return shift->handle->log_and_die(@_) }
sub log_and_croak  { return shift->handle->log_and_croak(@_) }

sub fatal     { shift->log( 'emergency', @_ ) }
sub emergency { shift->log( 'emergency', @_ ) }
sub alert     { shift->log( 'alert',     @_ ) }
sub critical  { shift->log( 'critical',  @_ ) }
sub warning   { shift->log( 'warning',   @_ ) }
sub warn      { shift->log( 'warning',   @_ ) }
sub notice    { shift->log( 'notice',    @_ ) }
sub debug    { shift->log( 'debug',    @_ ) }

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
sub is_debug     { shift->is_level('debug') }
sub is_info     { shift->is_level('info') }
sub is_error     { shift->is_level('error') }
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
