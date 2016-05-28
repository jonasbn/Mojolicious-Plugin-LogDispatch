use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    dist_author          => 'jonasbn', #author name
    dist_abstract        => 'Mojolicious plugin for Log::Dispatch', #short description
    module_name          => 'Mojolicious::Plugin::LogDispatch', #module name, resolves both name and version
    license              => 'artistic_2', 
    recursive_test_files => 0, #flag indicating whether t directory should be descended into recursively
    create_readme        => 0, #flag indicating whether README file should be auto-generated based on the file to which module_name points
    create_makefile_pl   => 'traditional', 
    configure_requires   => {},
    build_requires       => {},
    requires             => {
        'Mojolicious::Plugin' => '0',
    },
);
$build->create_build_script();