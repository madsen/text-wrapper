#---------------------------------------------------------------------
package Text::Wrapper;
#
# Copyright 1998 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created: 06 Mar 1998
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# ABSTRACT: Word wrap text by breaking long lines
#---------------------------------------------------------------------

use 5.010;
use strict;
use warnings;

use Carp qw(croak);

#=====================================================================
# Package Global Variables:

our $VERSION = '1.03';
# This file is part of {{$dist}} {{$dist_version}} ({{$date}})
our $AUTOLOAD;

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
    croak "Missing parameter" unless (scalar @_ % 2) == 1;

    my ($class, %param) = @_;

    my $self = bless {
        'bodyStart' => '',
        'columns'   => 70,
        'parStart'  => '',
    }, $class;

    $self->wrap_after(
      exists $param{wrap_after} ? delete $param{wrap_after} : '-'
    );

    my $value;
    while (($AUTOLOAD, $value) = each %param) {
      defined eval { &AUTOLOAD($self, $value) }
          or croak("Unknown parameter `$AUTOLOAD'");
    }

    $self;
} # end new

sub wrap_after
{
  my $self = shift;

  if (@_) {
    $self->{_wrapRE} = $self->_build_wrap_re(
      $self->{wrapAfter} = shift // ''
    );
  }

  $self->{wrapAfter};
} # end wrap_after

#---------------------------------------------------------------------
our %_wrap_re_cache;
our $hWS = ' \t\r\x{2000}-\x{200B}';

sub _build_wrap_re
{
  my ($self, $chars) = @_;

  return $_wrap_re_cache{$chars} ||= do {
    if (length $chars) {
      $chars =~ s/(.)/ sprintf '\x{%X}', ord $1 /seg;

      qr(
        [$hWS]*
        (?: [^$chars$hWS\n]+ |
            [$chars]+ [^$chars$hWS\n]* )
        [$chars]*
      )x;
    } else {
      qr( [$hWS]*  [^$hWS\n]+ )x;
    }
  };
} # end _build_wrap_re

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
    my $re       = $self->{_wrapRE};

    pos($_[0]) = 0;             # Make sure we start at the beginning
    for (;;) {
        if ($_[0] =~ m/\G[$hWS]*(\n+)/ogc) {
            $text .= $1 . $parStart;
            $lineStart = $length = $parStartLen;
        } else {
            $_[0] =~ m/\G($re)/g or last;
            my $word = $1;
          again:
            if (($length + length $word <= $width) or ($length == $lineStart)) {
                $length += length $word;
                $text .= $word;
            } else {
                $text .= $continue;
                $lineStart = $length = $contLen;
                $word =~ s/^[$hWS]+//o;
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

=head1 SYNOPSIS

    require Text::Wrapper;
    $wrapper = Text::Wrapper->new(columns => 60, body_start => '    ');
    print $wrapper->wrap($text);
    $wrapper->columns(70);

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


=attr body_start

The text that begins the second and following lines of
a paragraph.  (Default '')

=attr columns

The number of columns to use.  This includes any text
in body_start or par_start.  (Default 70)

=attr par_start

The text that begins the first line of each paragraph.
(Default '')

=attr wrap_after

A line can wrap after any of the characters in this string.  Setting
this to the empty string means a line will wrap only at whitespace.
(Default '-')


=method wrap

  $wrapper->wrap($text)

Returns a word wrapped copy of C<$text>.  The original is not altered.



=head1 DEPENDENCIES

None.


=head1 BUGS AND LIMITATIONS

Does not handle tabs (they're treated just like spaces).

All characters are treated as being the same width, including
zero-width spaces and combining accents.

Does not break words that can't fit on one line.

=for Pod::Coverage
new

=cut
