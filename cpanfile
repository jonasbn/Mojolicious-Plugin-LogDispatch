requires 'Mojolicious::Plugin';
requires 'Log::Dispatch';

on 'test' => sub {
  requires 'FindBin';
  requires 'Test::Mojo';
  requires 'Test::More','0.88';
  requires 'Test::Kwalitee', '1.21';      # from Dist::Zilla
  requires 'Pod::Coverage::TrustPod';     # from Dist::Zilla
  requires 'Test::Pod','1.41';            # from Dist::Zilla
  requires 'Test::Pod::Coverage', '1.08'; # from Dist::Zilla
};