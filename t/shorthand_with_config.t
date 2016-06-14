use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

use FindBin;
use lib "$FindBin::Bin/../lib";

my $cfg = {
    LogDispatch => {
        'Log::Dispatch::File' => {
            min_level => 'debug',
            newline   => 1,
            filename  => 'shorthand_with_config.log',
        },
    },
};

plugin 'LogDispatch', $cfg;

get '/' => sub {
  my $self = shift;

  $self->app->log->debug('Rendering Hello Mojo! for the whole world to see!');

  $self->render(text => 'Hello Mojo!');
};

my $t = Test::Mojo->new;
$t->get_ok('/')->status_is(200)->content_is('Hello Mojo!');

done_testing();
