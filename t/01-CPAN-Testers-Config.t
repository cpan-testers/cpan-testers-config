# Copyright (c) 2009 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

use strict;
use warnings;
use File::Spec;
use Test::More;

plan tests => 11;

my ($config);

#--------------------------------------------------------------------------#

require_ok( 'CPAN::Testers::Config' );

ok( local $ENV{HOME} = File::Spec->catdir(qw/t home fake/),
  "Setting \$ENV{HOME} for testing"
);

#--------------------------------------------------------------------------#

{
  $config = eval { CPAN::Testers::Config->read };
  is( $@, '', "read config file" );
  isa_ok( $config, 'CPAN::Testers::Config' );
  is( $config->{global}{profile}, 'profile.json', "found 'profile' in [global]" );

}

#--------------------------------------------------------------------------#

{
  ok( local $ENV{CPAN_TESTERS_CONFIG} = 'bogusfile',
    "Setting CPAN_TESTERS_CONFIG to non-existant file"
  );
  $config = eval { CPAN::Testers::Config->read };
  like( $@, qr/Error reading 'bogusfile': No such file or directory/, 
    "bogus file in CPAN_TESTERS_CONFIG gives error"
  );
}

#--------------------------------------------------------------------------#

{
  ok( local $ENV{CPAN_TESTERS_DIR} = File::Spec->catdir(qw/t home custom/),
    "Setting CPAN_TESTERS_DIR to custom config dir"
  );
  $config = eval { CPAN::Testers::Config->read };
  is( $@, '', "read config file" );
  isa_ok( $config, 'CPAN::Testers::Config' );
  is( $config->{global}{profile}, 'custom.json', "found 'profile' in [global]" );
}

