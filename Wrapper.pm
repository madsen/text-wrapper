#---------------------------------------------------------------------
package Text::Wrapper;
#
# Copyright 1998 Christopher J. Madsen
#
# Author: Christopher J. Madsen <ac608@yfn.ysu.edu>
# Created: 06 Mar 1998
# Version: $Revision: 0.3 $ ($Date: 1998/03/11 22:23:43 $)
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# Wrap text
#---------------------------------------------------------------------

require 5.000;
use Carp;
use strict;
use vars qw($VERSION);

#=====================================================================
# Package Global Variables:

BEGIN
{
    # Convert RCS revision number to d.ddd format:
    $VERSION = sprintf('%d.%03d', '$Revision: 0.3 $ ' =~ /(\d+)\.(\d+)/);
} # end BEGIN

#=====================================================================

sub new
{
    my ($package,%args) = @_;

    my $self = bless {
        'parStart'  => delete($args{parStart})  || '',
        'bodyStart' => delete($args{bodyStart}) || '',
        'columns'   => delete($args{columns})   || 70,
    }, $package;

    carp('Unknown arguments: ' . join ', ', keys %args) if keys %args;
    $self;
}

sub wrap
{
    my $self = shift;
    my $width = $self->{'columns'};
    my $text = $self->{'parStart'};
    my $length = length $text;
    my $lineStart = $length;
    my $parStart = $text;
    my $parStartLen = $length;
    my $continue = "\n" . $self->{'bodyStart'};
    my $contLen  = length $self->{'bodyStart'};
    while ($_[0] =~ m/(\s*\S+)/g) {
        my $word = $1;
      again:
        if ($word =~ s/[ \t]*(\n+)//) {
            $text .= $1 . $parStart;
            $lineStart = $length = $parStartLen;
            goto again;
        } elsif ($length + length $word <= $width) {
            $length += length $word;
            $text .= $word;
        } else {
            $text .= $continue;
            $lineStart = $length = $contLen;
            $word =~ s/^\s+//;
            goto again;
        }
    } # end while
    if ($length != $lineStart) { $text .= "\n" }
    else { $text =~ s/(?:\Q$continue\E|\n\Q$parStart)\Z/\n/ }

    $text;
}

#=====================================================================
# Package Return Value:

1;

__END__

# Local Variables:
# tmtrack-file-task: "Text::Wrapper.pm"
# End:
