package Mojolicious::Plugin::LogDispatch;

use strict;
use warnings;
use Mojo::Base qw(Mojolicious::Plugin);
use base qw(Mojo::Log); #inherting path

use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;

our $VERSION = '0.01';

use constant TRUE => 1; # for readability

sub register {
    my ( $self, $app, $conf ) = @_;

    $app->log->info('Registering Mojolicious::Plugin::LogDispatch');

    my $orig_log = $app->log;
    $self->orig_log($orig_log);

    my $path = $app->log->path;
    if ($path) {
        $app->log->debug("Resolved path: $path");
        $self->path($path);
    }

    #my $log = $self->handle();
    my $log = $self;
    if ($log) {
        $app->log->info('Instantiated LogDispatch outputters: '. join ',', map { ref $_ } $log->handle->outputs);
    }
    $app->log->info('Activating instantiated LogDispatch outputters: '. join ',', map { ref $_ } $log->handle->outputs);
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
            $self->orig_log->debug("we have a path: ", $self->path);

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
            if ($self->orig_log) {
                $self->orig_log->debug("we have no path, defaulting to screen");
            }

            # Create a logging object that will log to STDERR by default
            $dispatcher->add(
                Log::Dispatch::Screen->new(
                    'name'      => '_default_log_obj',
                    'min_level' => $self->level,
                    'stderr'    => TRUE,
                    'newline'   => TRUE,
                )
            );
        }

        if ($self->orig_log) {
            $self->orig_log->debug('returning dispatcher with logging outputters: '. map { ref $_ } $dispatcher->outputs);
        }

        return $dispatcher;
    }
);

__PACKAGE__->attr('orig_log');
__PACKAGE__->attr('callbacks');
#__PACKAGE__->attr('history'); #TODO
#__PACKAGE__->attr('message'); #TODO
#__PACKAGE__->attr('max_history_size'); #TODO
__PACKAGE__->attr( 'remove_default_log_obj' => TRUE );

# Methods from Log::Dispatch
sub add {
    my $self = shift;
    my $l    = $self->handle->add(@_);

    # Remove default log object that log to STDERR?
    $self->remove('_default_log_obj') if $self->remove_default_log_obj;

    return $l;
}

sub log {
    my ( $self, $level, @msgs ) = @_;

    # Check log level
    $level = lc $level;
    return $self unless $level && $self->is_level($level);

    $self->handle->log( 'level' => $level, 'message' => @msgs );
    return $self;
}

sub remove         { return shift->handle->remove(@_) }
sub output         { 
    my $self = shift;

    my $output = $self->handle->output(@_);

    return $output;
}
sub would_log      { return shift->handle->would_log(@_) }
sub log_to         { return shift->handle->log_to(@_) }
sub level_is_valid { return shift->handle->level_is_valid(@_) }
sub log_and_die    { return shift->handle->log_and_die(@_) }
sub log_and_croak  { return shift->handle->log_and_croak(@_) }

# log methods

sub emergency { shift->log( 'emergency', @_ ) }
sub emerg { shift->emergency( @_ ) }

sub alert     { shift->log( 'alert',     @_ ) }

sub fatal     { 
    my $self = shift;
    return $self->critical( @_ );
}

sub critical  { shift->log( 'critical',  @_ ) }
sub crit      { shift->critical( @_ ) }

sub error     {
    my $self = shift;
    return $self->log( 'error', @_ ) 
}
sub err       { shift->error(@_ ) }

sub warning   {
    my $self = shift;

    return $self->log( 'warning', @_ )     
}
sub warn      { shift->warning(@_) }

sub notice    { shift->log( 'notice',    @_ ) }

sub info      {
    my $self = shift;

    return $self->log( 'info', @_ );
}

sub debug     {
    my $self = shift;

    return $self->log( 'debug', @_ );
}

# log level methods

sub is_level {
    my ( $self, $level ) = @_;

    return 0 unless $level;
    $level = lc $level;
    return $self->would_log($level);
}

sub is_emergency { shift->is_level('emergency') }
sub is_emerg     { shift->is_level('emergency') }

sub is_alert     { shift->is_level('alert') }

sub is_fatal     { shift->is_level('critical') }
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

=head1 VERSION

This documentation describes version 0.01 of Mojolicious::Plugin::LogDispatch

=head1 SYNOPSIS

    # Mojolicious application using shorthand
    $self->plugin('LogDispatch');

    # Mojolicious application using longform
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
    $log->err('Do not divide by zero'); #error
    $log->crit('Do NOT divide by zero'); #critical 
    $log->emerg('Unable to render error message'); #emergency

    # If you want to add additional logging configuration to your Mojolicious application
    my $config = $self->plugin('Config');
    $self->plugin('Mojolicious::Plugin::LogDispatch' => $config->{LogDispatch} // {} );

    my $log = Mojolicious::Plugin::LogDispatch->new();

    # Setting up logging using LogDispatch in your application's startup  method
    my $dispatch = Mojolicious::Plugin::LogDispatch->new(
        'path' => '/path/to/my/logfile.log',
        'remove_default_log_obj' => 0, # removes default initialized log handler
    );

    # Adding an additional logger, logging to syslog
    $dispatch->add(Log::Dispatch::Syslog->new(
        name      => 'logsys',
        min_level => 'info',
        ident     => 'MyMojo::App',
        facility  => 'local0'
    ));

    $self->log($dispatch);
     
    #and then
    $self->log->debug("Why isn't this working?");  

=head1 DESCRIPTION

L<Mojolicious::Plugin::LogDispatch> is a L<Mojolicious> plugin for L<Log::Dispatch>

L<Mojolicious::Plugin::LogDispatch> is derived from L<MojoX::Log::Dispatch>, which was released
in the now deprecated Mojolicious plugin namespace. This distribution lifts the L<Log::Dispatch>
integration into the newer plugin namespace (see also MOTIVATION).

The component supports L<Mojo::Log> methods and is there for compatible with the default 
Mojolicious logging mechanism and it attempts to mimick this if no special configuration is added. 
The component also exposes the Log::Dispatch methods for logging. 

L<Mojolicious> via L<Mojo::Log> works with 5 log levels:

=over

=item * debug

=item * info

=item * warn

=item * error

=item * fatal

=back

Where Log::Dispatch works with 8 log levels, derived from Syslog.

=over

=item * debug

=item * info

=item * notice

=item * warning

=item * error

=item * critical

=item * alert

=item * emergency

=back

This mean that you can have higher differenciation on your logging statements using 
Log::Dispatch. The standard log levels from Mojolicious are mapped accordingly as 
depicted in the below figure:

=begin text

    +-----------+---------------+---------+
    | Mojo::Log | Log::Dispatch | Syslog  |
    +-----------+---------------+---------+
    |           | emergency     | emerg   |
    |           | alert         | alert   |
    | fatal     | critical      | crit    |
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
|           | emergency     | emerg   |
|           | alert         | alert   |
| fatal     | critical      | crit    |
| error     | error         | err     |
| warn      | warning       | warning |
|           | notice        | notice  |
| info      | info          | info    |
| debug     | debug         | debug   |

=end markdown


=head1 SUBROUTINES/METHODS

L<Mojolicious::Plugin::LogDispatch> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

In addition L<Mojolicious::Plugin::LogDispatch> inherits from L<Mojo::Log>

=head2 add

=head2 log

=head2 log_and_croak

=head2 log_and_die

=head2 log_to

=head2 output

=head2 remove

=head2 would_log

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

This is a part of the L<Mojolicious> plugin API and it not used directly if you just want 
to use L<Mojolicious::Plugin::LogDispatch> for logging.

=head2 LOG METHODS

=head3 debug

    $log->debug('How the helicopter did we get here?');

=head3 info

    $log->info('J.F.Y.I');

=head3 notice

    $log->notice ('J.F.Y.I');

=head3 warning / warn

    $log->warning('What are you trying to do Dave?');

=head3 error / err

    $log->err('Do not divide by zero');

=head3 critical / crit

    $log->critical('Do NOT divide by zero');

=head3 alert

    $log->alert('Seriously! do NOT divide by zero');

=head3 fatal / emergency / emerg

    $log->emerg('Unable to render error message');

=head2 LOG LEVEL METHODS

=head3 level_is_valid

A method lifted from L<Log::Dispatch> returns 

    $log->level_is_valid("PANIC!");

    $log->level_is_valid("DEFCON 5");

See also: L<https://metacpan.org/pod/Log::Dispatch#dispatch-level_is_valid-string>

=head3 is_alert

    # TODO

=head3 is_crit

    # TODO

=head3 is_critical

    # TODO

=head3 is_debug

    # TODO

=head3 is_emerg

    # TODO

=head3 is_emergency

    # TODO

=head3 is_err

    # TODO

=head3 is_error

    # TODO

=head3 is_fatal

    # TODO

=head3 is_info

    # TODO

=head3 is_notice

    # TODO

=head3 is_warn

    # TODO

=head3 is_warning

    # TODO

=head1 COMPATIBILITY

=head2 Mojo::Log

    # TODO

=head2 Log::Dispatch

    # TODO

=head1 INCOMPATIBILITIES

=head2 MojoX::Log::Dispatch

    # TODO

=head1 CONFIGURATION AND ENVIRONMENT

One of the great features of Mojolicious is it's ability to run with segregated 
configurations based on the mode in which the application is running.

If we would have an Mojolicious application with 5 supported methods:

=over

=item * development

=item * test

=item * staging

=item * sandbox

=item * production

=back

The example configurations could look like the following:

Example development configuration:

    # myapp.development.conf
    LogDispatch => {
        file => {
            min_level => 'debug',
            newline => 1,
        },
    },

Example test configuration:

    # myapp.test.conf
    LogDispatch => {
        file => {
            min_level => 'info',
            newline => 1,
        },
    },

Example staging configuration:

    # myapp.staging.conf
    LogDispatch => {
        file => {
            min_level => 'info',
            newline   => 1,
        },
    },

Example sandbox configuration:

    # myapp.sandbox.conf
    LogDispatch => {
        Syslog => {
            min_level => 'warn',
            newline   => 1,
            ident     => 'myapp',
            facility  => 'local0',
        },
        'Log::Dispatch::Email::MailSender' => {
            min_level => 'critical',
            newline   => 1,
            subject   => 'MyApp (sandbox)',
            from      => 'myapp+sandbox@mydomain.io',
            to        => [ 'operations@mydomain.io' ],
        },
    },

Example production configuration:

    # myapp.production.conf
    LogDispatch => {
        Syslog => {
            min_level => 'warn',
            newline   => 1,
            ident     => 'myapp',
            facility  => 'local0',
        },
        'Log::Dispatch::Email::MailSender' => {
            min_level => 'critical',
            newline   => 1,
            subject   => 'MyApp (production)',
            from      => 'myapp+production@mydomain.io',
            to        => [ 'operations@mydomain.io' ],
        },
    },

=head1 BUGS AND LIMITATIONS

    # TODO

=head1 DIAGNOSTICS

    # TODO

=head1 DEPENDENCIES

=over

=item * L<Mojo::Base>

=item * L<Mojolicious::Plugin>

=item * L<Mojo::Log>

=item * L<Log::Dispatch>

=item * L<Log::Dispatch::File>

=item * L<Log::Dispatch::Screen>

=back

=head1 TODO

Please see the issue list on Github for a complete list, since this list
is just sort of a draft of future improvements and ideas.

=over

=item * Support for format method from L<Mojo::Log>

=back

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

The lack of support on L<MojoX::Log::Dispatch> resulted in this distribution. See L<RT:91305|https://rt.cpan.org/Public/Bug/Display.html?id=91305>
for an example.

=head ACKNOWLEDGEMENTS

=over

=item * Konstantin Kapitanov, (KAKADU), author of L<MojoX::Log::Dispatch>, cool module and the base of this module

=item * Dave Rolsky (DROLSKY), author of L<Log::Dispatch>

=item * Sebastian Riedel (SRI) and the team behind L<Mojolicious>

=back 

=head1 AUTHOR

Jonas B. Nielsen, (jonasbn) - C<< <jonasbn@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

The implementation is derived from L<MojoX::Log::Dispatch> which is no longer 
actively supported

Mojolicious-Plugin-LogDispatch is (C) by Jonas B. Nielsen, (jonasbn) 2016

Mojolicious-Plugin-LogDispatch is released under the Artistic License 2.0

MojoX::Log::Dispatch is (C) by Konstantin Kapitanov, (kakadu) 2009 all rights reserved.

=cut
