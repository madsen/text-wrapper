#---------------------------------------------------------------------
package Text::Wrapper;
#
# Copyright 1998 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created: 06 Mar 1998
# $Id$
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# Word wrap text by breaking long lines
#---------------------------------------------------------------------

require 5.004;
use Carp;
use strict;
use vars qw($AUTOLOAD $VERSION);

#=====================================================================
# Package Global Variables:

BEGIN
{
    $VERSION = '1.02';
} # end BEGIN

#=====================================================================
# Methods:
#---------------------------------------------------------------------
# Provide methods for getting/setting fields:

sub AUTOLOAD
{
    my $self = $_[0];
    my $type = ref($self) or croak("$self is not an object");
    my $name = $AUTOLOAD;
    $name =~ s/.*://;   # strip fully-qualified portion
    my $field = $name;
    $field =~ s/_([a-z])/\u$1/g; # squash underlines into mixed case
    unless (exists $self->{$field}) {
        # Ignore special methods like DESTROY:
        return undef if $name =~ /^[A-Z]+$/;
        croak("Can't locate object method \"$name\" via package \"$type\"");
    }
    return $self->{$field} = $_[1] if $#_;
    $self->{$field};
} # end AUTOLOAD

#---------------------------------------------------------------------
sub new
{
    my $self = bless {
        'bodyStart' => '',
        'columns'   => 70,
        'parStart'  => '',
    }, shift;

    croak "Missing parameter" unless (scalar @_ % 2) == 0;
    while (@_) {
        $AUTOLOAD = shift;
        defined eval { &AUTOLOAD($self, shift) }
        or croak("Unknown parameter `$AUTOLOAD'");
    }

    $self;
} # end new

#---------------------------------------------------------------------
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
            if (($length + length $word <= $width) or ($length == $lineStart)) {
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

=head1 VERSION

This document describes $Id$


=head1 SYNOPSIS

    require Text::Wrapper;
    $wrapper = Text::Wrapper->new(columns => 60, body_start => '    ');
    print $wrapper->wrap($text);

=head1 DESCRIPTION

Text::Wrapper provides simple word wrapping.  It breaks long lines,
but does not alter spacing or remove existing line breaks.  If you're
looking for more sophisticated text formatting, try the
L<Text::Format> module.

Reasons to use Text::Wrapper instead of Text::Format:

=over 4

=item *

Text::Wrapper is significantly smaller.

=item *

It does not alter existing whitespace or combine short lines.
It only breaks long lines.

=back

Again, if Text::Wrapper doesn't meet your needs, try
Text::Format.

=head2 Methods

=over 4

=item $wrapper = Text::Wrapper->new( [options] )

Constructs a new Text::Wrapper object.  The options are specified
by key and value.  The keys are:

 body_start  The text that begins the second and following lines of
             a paragraph.  (Default '')

 columns     The number of columns to use.  This includes any text
             in body_start or par_start.  (Default 70)

 par_start   The text that begins the first line of each paragraph.
             (Default '')

=item $wrapper->body_start( [$value] )

=item $wrapper->columns( [$value] )

=item $wrapper->par_start( [$value] )

If C<$value> is supplied, sets the option and returns the previous value.
If omitted, just returns the current value.

=item $wrapper->wrap($text)

Returns a word wrapped copy of C<$text>.  The original is not altered.

=back


=head1 DEPENDENCIES

None.


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

Does not handle tabs (they're treated just like spaces).

Does not break words that can't fit on one line.


=head1 AUTHOR

Christopher J. Madsen  S<< C<< <perl AT cjmweb.net> >> >>

Please report any bugs or feature requests to
S<< C<< <bug-Text-Wrapper AT rt.cpan.org> >> >>,
or through the web interface at
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=Text-Wrapper>


=head1 LICENSE AND COPYRIGHT

Copyright 1998 Christopher J. Madsen

Text::Wrapper is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
