package Mojolicious::Plugin::LogDispatch;

use strict;
use warnings;
use Mojo::Base qw(Mojolicious::Plugin);
use base qw(Mojo::Log); #inherting path

use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;

our $VERSION = '0.01';

use constant TRUE => 1;

sub register {
    my ( $self, $app, $conf ) = @_;

    $app->log->info('Registering Mojolicious::Plugin::LogDispatch');

    my $path = $app->log->path;
    if ($path) {
        $app->log->debug("Resolved path: $path");
        $self->path($path);
    }

    my $log = $self->handle();
    if ($log) {
        $app->log->info('Instantiated LogDispatch outputters: '. join ',', map { ref $_ } $log->outputs);
    }
    $app->log->info('Activating instantiated LogDispatch outputters: '. join ',', map { ref $_ } $log->outputs);
    $app->log($log);

    return;
}

__PACKAGE__->attr(
    'handle' => sub {
        my $self = shift;

        my $dispatcher;

        if ( $self->callbacks ) {
            $dispatcher = Log::Dispatch->new( callbacks => $self->callbacks );
        }
        else {
            $dispatcher = Log::Dispatch->new(@_);
        }

        if ( $self->path ) {
            # Create a logging object that will log to a file if we have a path
            $dispatcher->add(
                Log::Dispatch::File->new(
                    'name'      => '_default_log_obj',
                    'min_level' => $self->level,
                    'filename'  => $self->path,
                    'newlines'  => TRUE,
                    'mode'      => 'append',
                )
            );
        }
        else {
            # Create a logging object that will log to STDERR by default
            $dispatcher->add(
                Log::Dispatch::Screen->new(
                    'name'      => '_default_log_obj',
                    'min_level' => $self->level,
                    'stderr'    => TRUE,
                )
            );
        }

        return $dispatcher;
    }
);

__PACKAGE__->attr('callbacks');
__PACKAGE__->attr( 'remove_default_log_obj' => TRUE );

#some methods from Log::Dispatch
sub add {
    my $self = shift;
    my $l    = $self->handle->add(@_);

    # Remove default log object that log to STDERR?
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
sub emerg { shift->log( 'emergency', @_ ) }

sub alert     { shift->log( 'alert',     @_ ) }

sub critical  { shift->log( 'critical',  @_ ) }
sub crit      { shift->log( 'critical',  @_ ) }

sub error     { shift->log( 'error',     @_ ) }
sub err       { shift->log( 'error',     @_ ) }

sub warning   { shift->log( 'warning',   @_ ) }
sub warn      { shift->log( 'warning',   @_ ) }

sub notice    { shift->log( 'notice',    @_ ) }

sub info      { shift->log( 'info',    @_ ) }

sub debug     { shift->log( 'debug',     @_ ) }

sub is_level {
    my ( $self, $level ) = @_;

    return 0 unless $level;
    $level = lc $level;
    return $self->would_log($level);
}

sub is_fatal     { shift->is_level('emergency') }
sub is_emergency { shift->is_level('emergency') }
sub is_emerg     { shift->is_level('emergency') }

sub is_alert     { shift->is_level('alert') }

sub is_critical  { shift->is_level('critical') }
sub is_crit      { shift->is_level('critical') }

sub is_error     { shift->is_level('error') }
sub is_err       { shift->is_level('error') }

sub is_warning   { shift->is_level('warning') }
sub is_warn      { shift->is_level('warning') }

sub is_notice    { shift->is_level('notice') }

sub is_info      { shift->is_level('info') }

sub is_debug     { shift->is_level('debug') }

1;

__END__

=pod

=encoding utf8

=head1 NAME

Mojolicious::Plugin::LogDispatch - Mojolicious Plugin

=head1 SYNOPSIS

    # Mojolicious using shorthand
    $self->plugin('LogDispatch');

    # Mojolicious using longform
    $self->plugin('Mojolicious::Plugin::LogDispatch');

    # Mojolicious::Lite using shorthand
    plugin 'LogDispatch';

    # Mojolicious::Lite using longform
    $self->plugin('Mojolicious::Plugin::LogDispatch');

    # Mojo::Log compatibility
    $log->debug('How the helicopter did we get here?');
    $log->info('J.F.Y.I');
    $log->warn('What are you trying to do Dave?');
    $log->error('Do not divide by zero');
    $log->fatal('Unable to render error message');    
    
    # Log::Dispatch compatibility
    $log->notice ('J.F.Y.I');
    $log->warning('What are you trying to do Dave?');
    $log->critical('Do NOT divide by zero');
    $log->alert('Seriously! do NOT divide by zero');
    $log->emergency('Unable to render error message');

    # Syslog compatibility
    $log->err('Do not divide by zero');
    $log->crit('Do NOT divide by zero');
    $log->emerg('Unable to render error message');


my $log = Mojolicious::Plugin::LogDispatch->new();

=head1 DESCRIPTION

L<Mojolicious::Plugin::LogDispatch> is a L<Mojolicious> plugin for L<Log::Dispatch>

L<Mojolicious::Plugin::LogDispatch> is derived from L<MojoX::Log::Dispatch>, which released
in the deprecated Mojolicious plugin namespace. This distribution lifts the Log::Dispatch 
integration into the newer plugin namespace (see also MOTIVATION).

The component supports Mojo::Log methods and is there for compatible with the default 
Mojolicious logging mechanism and it attempts to mimick this if no special configuration is added. 
The component also exposes the Log::Dispatch methods for logging. Mojolicious only works with 5 log levels:

=over

=item debug

=item info

=item warn

=item error

=item fatal

=back

Where Log::Dispatch works with 8, derived from Syslog.

=over

=item debug

=item info

=item notice

=item warning

=item error

=item critical

=item alert

=item emergency

=back

This mean that you can have higher differenciation on your logging statements using 
Log::Dispatch. The standard log levels from Mojolicious are mapped accordingly as 
depicted in the below figure:

=begin text

+-----------+---------------+---------+
| Mojo::Log | Log::Dispatch | Syslog  |
+-----------+---------------+---------+
| fatal     | emergency     | emerg   |
|           | alert         | alert   |
|           | critical      | crit    |
| error     | error         | err     |
| warn      | warning       | warning |
|           | notice        | notice  |
| info      | info          | info    |
| debug     | debug         | debug   |
+-----------+---------------+---------+

=end text

=begin markdown

| Mojo::Log | Log::Dispatch | Syslog  |
| --------- | ------------- | ------- |
| fatal     | emergency     | emerg   |
|           | alert         | alert   |
|           | critical      | crit    |
| error     | error         | err     |
| warn      | warning       | warning |
|           | notice        | notice  |
| info      | info          | info    |
| debug     | debug         | debug   |

=end markdown

Mojolicious::Plugin::LogDispatch

=head1 METHODS

L<Mojolicious::Plugin::LogDispatch> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head2 debug

    $log->debug('How the helicopter did we get here?');

=head2 info

    $log->info('J.F.Y.I');

=head2 notice

    $log->notice ('J.F.Y.I');

=head2 warning / warn

    $log->warning('What are you trying to do Dave?');

=head2 error / err

    $log->err('Do not divide by zero');

=head2 critical / crit

    $log->critical('Do NOT divide by zero');

=head2 alert

    $log->alert('Seriously! do NOT divide by zero');

=head2 fatal / emergency / emerg

    $log->emerg('Unable to render error message');

=head1 SEE ALSO

=over

=item L<Mojolicious>

=item L<Mojolicious::Guides>

=item L<http://mojolicio.us>.

=item L<Log::Dispatch>

=item L<MojoX::Log::Dispatch>

=item L<https://en.wikipedia.org/wiki/Syslog>

=back

=head1 MOTIVATION

The lack of support on MojoX::Log::Dispatch resulted in this distribution.

=head1 AUTHOR

Jonas B. Nielsen, (jonasbn) - C<< <jonasbn@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

The implementation is derived from MojoX::Log::Dispatch which is no longer 
supported

Mojolicious-Plugin-LogDispatch is (C) by Jonas B. Nielsen, (jonasbn) 2016

Mojolicious-Plugin-LogDispatch is released under the Artistic License 2.0

MojoX::Log::Dispatch is (C) by Konstantin Kapitanov, (kakadu) 2009 all rights reserved.

=cut
