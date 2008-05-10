#! /usr/bin/perl
#---------------------------------------------------------------------
# $Id$
# Copyright 2007 Christopher J. Madsen
#
# Build.PL for Text-Wrapper
#---------------------------------------------------------------------

use strict;
#use warnings;         # Wasn't core until 5.6.0

use FindBin;
use lib $FindBin::Bin; # Make sure we're using My_Build from our distribution

use Module::Build;
eval 'use Module::Build::DistVersion;';
my $class = ($@ ? Module::Build->subclass(code => q{
    sub ACTION_distdir {
      print STDERR <<"END";
\a\a\a\n
This module uses Module::Build::DistVersion to automatically copy
version numbers to the appropriate places.  You might want to install
that and re-run Build.PL if you intend to create a distribution.
\n
END
      (shift @_)->SUPER::ACTION_distdir(@_);
    } })
             : 'Module::Build::DistVersion'); # if we found it

my $builder = $class->new(
  module_name        => 'Text::Wrapper',
  license            => 'perl',
  dist_author        => 'Christopher J. Madsen <perl@cjmweb.net>',
  requires           => { perl => 5.004 },
  build_requires => {
      'FindBin'       => 0,
      'File::Spec'    => 0,
      'Module::Build' => 0.21,
      'Test::More'    => 0,
  },
  create_makefile_pl => 'passthrough',
  dynamic_config     => 0,
  meta_merge         => { no_index => { directory => [ 'tools' ] }},
);

$builder->create_build_script();
