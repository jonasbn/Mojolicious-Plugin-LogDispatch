#!/usr/bin/env perl
use Mojolicious::Lite;

use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/../lib";

plugin 'Mojolicious::Plugin::LogDispatch';

get '/' => sub {
    my $self = shift;
    $self->app->log->debug('calling /');
    $self->app->log->debug('logging using debug');
    $self->render( 'index', level => 'debug' );
};

get '/debug' => sub {
    my $self = shift;
    $self->app->log->debug('calling /debug');
    $self->app->log->debug('logging using debug');
    $self->render( 'index', level => 'debug' );
};

get '/info' => sub {
    my $self = shift;

    $self->app->log->debug('calling /info');
    $self->app->log->info('logging using info');
    $self->render( 'index', level => 'info' );
};

get '/warn' => sub {
    my $self = shift;

    $self->app->log->debug('calling /warn');
    $self->app->log->warn('logging using warn');
    $self->render( 'index', level => 'warn' );
};

get '/error' => sub {
    my $self = shift;
    $self->app->log->debug('calling /error');
    $self->app->log->error('logging using error');
    $self->render( 'index', level => 'error' );
};

get '/fatal' => sub {
    my $self = shift;
    $self->app->log->debug('calling /fatal');
    $self->app->log->fatal('logging using fatal');
    $self->render( 'index', level => 'fatal' );
};

app->start;

__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
We are logging with level:

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title>
  </head>
  <body>Log level: <%= $level %></body>
</html>
