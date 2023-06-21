requires 'Mojolicious::Plugin';
requires 'Log::Dispatch';
requires 'Log::Dispatch::File';
requires 'Log::Dispatch::Screen';
requires 'DateTime';

on 'test' => sub {
    requires 'File::Temp';
    requires 'FindBin';
    requires 'Test::Mojo';
    requires 'Test::More',     '0.88';
    requires 'Test::Kwalitee', '1.21';    # from Dist::Zilla
    requires 'Test::Pod',      '1.52';    # from Dist::Zilla
    requires 'Pod::Coverage::TrustPod';   # from Dist::Zilla
    requires 'Test::Pod::Coverage', '1.10';    # from Dist::Zilla
};
