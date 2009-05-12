# Copyright (c) 2009 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

use 5.006;
use strict;
use warnings;
use lib 'inc';
eval "require Pod::WikiDoc";
my $class = $@ ? "Module::Build" : "Module::Build::WikiDoc";
eval "require $class";
my $build = $class->new( 
    module_name => 'CPAN::Testers::Config',
    dist_author => 'David Golden <dagolden@cpan.org>',
    license => 'apache',
    create_readme => 1,
    create_makefile_pl  => 'traditional',
    requires => {
        'perl' => 5.006,
        'Carp' => 0,
        'Data::Dumper' => 0,
        'File::Basename' => 0,
        'File::HomeDir' => 0.86,
        'File::Path' => 0,
        'File::Spec' => 0.86, 
    },
    build_requires => {
        'File::Find' => 0,
        'File::Temp' => 0.16, 
        'Test::More' => 0.62,
    },
    meta_add            => { 
        no_index => { 
            directory => [ qw/ examples inc t xt /],
        },
        resources => {
          repository => "http://github.com/dagolden/cpan-testers-config/", 
          bugtracker => "http://rt.cpan.org/NoAuth/Bugs.html?Dist=CPAN-Testers-Config",
        },
    },
);
$build->create_build_script;

