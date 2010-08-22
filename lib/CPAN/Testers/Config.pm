use 5.006;
use strict;
use warnings;
package CPAN::Testers::Config;
# ABSTRACT: Manage CPAN Testers configuration data

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
  $file = $self->config_file unless defined $file;

  open my $fh, "<", $file or Carp::confess("Error reading '$file': $!");
  my $data = eval do {local $/; <$fh>}; ## no critic
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
  $file = $self->config_file unless defined $file;

  File::Path::mkpath( File::Basename::dirname( $file ) );
  open my $fh, ">", $file or Carp::confess("Error writing '$file': $!");
  print {$fh} $self->_data_dump;
  close $fh;
  return $self;
}

#--------------------------------------------------------------------------#
# config_dir -- get config directory name, given %ENV overrides
#--------------------------------------------------------------------------#

sub config_dir {
  my ($self) = @_;
  return  $ENV{CPAN_TESTERS_DIR}
      ||  File::Spec->catdir(File::HomeDir->my_home, '.cpantesters');
}

#--------------------------------------------------------------------------#
# config_file -- get config file name, given %ENV overrides
#--------------------------------------------------------------------------#

sub config_file {
  my ($self) = @_;
  my $path = $ENV{CPAN_TESTERS_CONFIG} || 'config.pl';
  my $file = File::Spec->file_name_is_absolute($path)
           ? $path
           : File::Spec->catfile($self->config_dir, $path) ;
  return $file
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

= SYNOPSIS

    use CPAN::Testers::Config;

    $config = CPAN::Testers::Config->read;
    $config->{global}{profile} = 'my_profile.json';
    $config->write;

= DESCRIPTION

CPAN::Testers::Config provides a very simple interface to load and save CPAN
Testers configuration data using only core Perl modules.

By default, configuration is stored in '.cpantesters/config.pl' in the user's
home directory.  Data is serialized using [Data::Dumper].

= SCHEMA

Configuration is provided as a hash of hashes.  No formal schema has been
defined yet for CPAN Testers configuration and thus there is no validation by
this module.

The top-level key {global} is reserved for data that will be used by multiple
CPAN Testers modules.  Only keys listed in the [/Global Configuration Keys]
section should be used in the {global} hash.

Module-specific configuration data should be stored under a top-level key
corresponding to the module name.  For example:

  # global
  $metabase_profile = $config->{global}{profile};

  # module-specific
  $config->{'CPAN::Testers::Client'}{send_duplicates} = 1;

== Global Configuration Keys

The following key(s) are defined. No other keys should be added or expected.

Proposed new global keys should be sent to the maintainer(s) of this module
and/or the [CPAN Testers Discussion|https://www.socialtext.net/perl5/index.cgi?cpan_testers]
mailing list.

=== {profile}

A path to a filename containing a CPAN Testers 2.0 user profile; if not an
absolute path, it should be treated as a path relative to the CPAN Testers
configuration directory

= USAGE

== new

  $config = CPAN::Testers::Config->new( %data );

Creates and returns a new configuration object with optional starting data or
dies.

== read

  $config = CPAN::Tester::Config->read;
  # ... modify $config ...
  $config->read; # reload

Returns a configuration object with data loaded from the configuration file or
dies.  May be called either as a class method or an object method.

== write

  $config->write;

Serializes a configuration object to the the configuration file or dies.
Returns the object as a convenience on success.

== config_dir

  $dir = CPAN::Testers::Config->config_dir;

Returns a path to the CPAN Testers configuration directory.  See [/ENVIRONMENT].

== config_file

  $file = CPAN::Testers::Config->config_file;

Returns a path to the CPAN Testesr configuration file.  See [/ENVIRONMENT].

= ENVIRONMENT

== CPAN_TESTERS_DIR

Specifies an alternate directory to search for CPAN Testers configuration files
instead of the default '.cpantesters' in the user's home directory.

== CPAN_TESTERS_CONFIG

Specifies an alternate file for configuration data instead of 'config.pl' in
the default or alternate configuration directory.

=end wikidoc

=cut

