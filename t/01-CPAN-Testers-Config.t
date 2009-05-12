# Copyright (c) 2009 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

use strict;
use warnings;
use File::Temp ();
use Test::More;

plan tests => 13;

my ($config);
my %data = ( global => { profile => 'profile.json' } );

#--------------------------------------------------------------------------#

require_ok( 'CPAN::Testers::Config' );

ok( local $ENV{HOME} = File::Temp->newdir, 
  "setting \$ENV{HOME} to temp directory for testing"
);

#--------------------------------------------------------------------------#

SKIP: {
  eval { CPAN::Testers::Config->new(%data)->write };
  is( $@, '', "wrote config file without error" ) 
    or skip "no config to read", 3;
  $config = eval { CPAN::Testers::Config->read };
  is( $@, '', "read config file without error" );
  isa_ok( $config, 'CPAN::Testers::Config' );
  is( $config->{global}{profile}, 'profile.json', "found 'profile' in [global]" );

}

#--------------------------------------------------------------------------#

{
  ok( local $ENV{CPAN_TESTERS_CONFIG} = 'bogusfile',
    "setting CPAN_TESTERS_CONFIG to non-existant file"
  );
  $config = eval { CPAN::Testers::Config->read };
  like( $@, qr/Error reading 'bogusfile': No such file or directory/, 
    "bogus file in CPAN_TESTERS_CONFIG gives error"
  );
}

#--------------------------------------------------------------------------#

SKIP: {
  ok( local $ENV{CPAN_TESTERS_DIR} = File::Temp->newdir,
    "setting CPAN_TESTERS_DIR to new temp config directory"
  );
  eval { CPAN::Testers::Config->new(%data)->write };
  is( $@, '', "wrote config file without error" ) 
    or skip "no config to read", 3;
  $config = eval { CPAN::Testers::Config->read };
  is( $@, '', "read config file" );
  isa_ok( $config, 'CPAN::Testers::Config' );
  is( $config->{global}{profile}, 'profile.json', "found 'profile' in [global]" );
}

