requires 'Mojolicious::Plugin';
requires 'Log::Dispatch';

on 'test' => sub {
  requires 'FindBin';
  requires 'Test::More';
  requires 'Test::Mojo';
};