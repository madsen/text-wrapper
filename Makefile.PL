# $Id: Makefile.PL,v 0.1 1998/05/14 22:25:07 Madsen Exp $

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Text::Wrapper',
    'VERSION_FROM' => 'Wrapper.pm', # finds $VERSION
    'dist'	=> {COMPRESS => 'gzip -9f', SUFFIX => 'gz',
# This next line is just for my own use, you should comment it out:
                    PREOP => 'cjm_fixup $(DISTVNAME)' # Converts CRLF to LF
                   }
);
