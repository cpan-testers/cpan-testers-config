# Copyright (c) 2009 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

package CPAN::Testers::Config;
use 5.006;
use strict;
use warnings;

our $VERSION = '0.001';
$VERSION = eval $VERSION; ## no critic

use Carp            ();
use Data::Dumper    ();
use File::Basename  ();
use File::HomeDir   ();
use File::Path      ();
use File::Spec      ();

#--------------------------------------------------------------------------#
# new -- construct empty object
#--------------------------------------------------------------------------#

sub new {
  my ($class, @args) = @_;
  Carp::confess( "\$class->new() requires an even number of arguments" )
    if @args % 2;
  return bless { @args }, $class;
}

#--------------------------------------------------------------------------#
# read -- load data from config file
#--------------------------------------------------------------------------#

sub read {
  my ($self, $file) = @_;
  $self = $self->new unless ref $self; # if called as class method
  $file = $self->_config_file unless defined $file;

  open my $fh, "<", $file or Carp::confess("Error reading '$file': $!");
  my $data = eval do {local $/; <$fh>};
  if ( ref $data eq 'HASH' ) {
    %$self = %$data;
  }
  else {
    my $err = $@ ? $@ : "did not eval() to a perl hash";
    Carp::confess("Could not eval config file '$file': $err");
  }
  return $self;
}

#--------------------------------------------------------------------------#
# write -- save data to config file
#--------------------------------------------------------------------------#

sub write {
  my ($self, $file) = @_;
  $self = $self->new unless ref $self; # class method will write empty file
  $file = $self->_config_file unless defined $file;

  File::Path::mkpath( File::Basename::dirname( $file ) );
  open my $fh, ">", $file or Carp::confess("Error writing '$file': $!");
  print {$fh} $self->_data_dump;
  close $fh;
  return $self;
}

#--------------------------------------------------------------------------#
# _config_file -- find config file, given %ENV overrides
#--------------------------------------------------------------------------#

sub _config_file {
  my $config_dir  = $ENV{CPAN_TESTERS_DIR} 
                  ||  File::Spec->catdir(File::HomeDir->my_home, '.cpantesters');
  return $ENV{CPAN_TESTERS_CONFIG} || 
         File::Spec->catfile($config_dir, 'config.pl');
}

#--------------------------------------------------------------------------#
# _data_dump -- Copied from Module::Build::Dumper
#--------------------------------------------------------------------------#

sub _data_dump {
  my ($self) = @_;
  my %data = %$self;
  return ("do{ my "
      . Data::Dumper->new([\%data],['x'])->Purity(1)->Terse(0)->Dump()
      . '$x; }')
}

1;

__END__

=begin wikidoc

= NAME

CPAN::Testers::Config - Interface to CPAN Testers configuration

= VERSION

This documentation describes version %%VERSION%%.

= SYNOPSIS

    use CPAN::Testers::Config;

= DESCRIPTION


= USAGE


= BUGS

Please report any bugs or feature requests using the CPAN Request Tracker  
web interface at [http://rt.cpan.org/Dist/Display.html?Queue=CPAN-Testers-Config]

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

= SEE ALSO


= AUTHOR

David A. Golden (DAGOLDEN)

= COPYRIGHT AND LICENSE

Copyright (c) 2009 by David A. Golden. All rights reserved.

Licensed under Apache License, Version 2.0 (the "License").
You may not use this file except in compliance with the License.
A copy of the License was distributed with this file or you may obtain a 
copy of the License from http://www.apache.org/licenses/LICENSE-2.0

Files produced as output though the use of this software, shall not be
considered Derivative Works, but shall be considered the original work of the
Licensor.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end wikidoc

=cut

