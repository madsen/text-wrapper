#---------------------------------------------------------------------
package Text::Wrapper;
#
# Copyright 1998 Christopher J. Madsen
#
# Author: Christopher J. Madsen <ac608@yfn.ysu.edu>
# Created: 06 Mar 1998
# Version: $Revision: 0.5 $ ($Date: 1998/03/16 02:21:54 $)
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
    $VERSION = sprintf('%d.%03d', '$Revision: 0.5 $ ' =~ /(\d+)\.(\d+)/);
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
} # end new

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
    pos($_[0]) = 0;             # Make sure we start at the beginning
    for (;;) {
        if ($_[0] =~ m/\G[ \t]*(\n+)/gc) {
            $text .= $1 . $parStart;
            $lineStart = $length = $parStartLen;
        } else {
            $_[0] =~ m/\G(\s*(?:[^-\s]+-*|\S+))/g or last;
            my $word = $1;
          again:
            if ($length + length $word <= $width) {
                $length += length $word;
                $text .= $word;
            } else {
                $text .= $continue;
                $lineStart = $length = $contLen;
                $word =~ s/^\s+//;
                goto again;
            }
        }
    } # end forever
    if ($length != $lineStart) { $text .= "\n" }
    else { $text =~ s/(?:\Q$continue\E|\n\Q$parStart\E)\Z/\n/ }

    $text;
} # end wrap

#=====================================================================
# Package Return Value:

1;

__END__

=head1 NAME

Text::Wrapper - Simple word wrapping routine

=head1 SYNOPSIS

    require Text::Wrapper;
    $wrapper = Text::Wrapper->new(columns=>60);
    print $wrapper->wrap($text);

=head1 DESCRIPTION

B<Text::Wrapper> provides simple word wrapping.  It breaks long lines,
but does not alter spacing or remove existing line breaks.  If you're
looking for more sophisticated text formatting, try the
B<Text::Format> module.

Reasons to use B<Text::Wrapper> instead of B<Text::Format>:

=over 4

=item *

B<Text::Wrapper> is significantly smaller.

=item *

It does not alter existing whitespace or combine short lines.
It only breaks long lines.

=back

Again, if B<Text::Wrapper> doesn't meet your needs, try
B<Text::Format>.

=head2 Methods

=over 4

=item $wrapper = Text::Wrapper->new([options])

Constructs a new B<Text::Wrapper> object.

=item $wrapper->wrap($text)

Returns a word wrapped copy of C<$text>.

=head1 BUGS

Does not handle tabs (they're treated just like spaces).

=head1 AUTHOR

Christopher J. Madsen E<lt>F<ac608@yfn.ysu.edu>E<gt>

=cut

# Local Variables:
# tmtrack-file-task: "Text::Wrapper.pm"
# End:
