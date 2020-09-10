package String::TtyLength;

use 5.006;
use strict;
use warnings;
use parent 'Exporter';

# RECOMMEND PREREQ: Text::CharWidth 0.04
BEGIN {
    eval "use Text::CharWidth ();";
}

our @EXPORT_OK = qw/ tty_length tty_width /;

my $cursor_position     = qr/\e\[[0-9]+;[0-9]+[Hf]/;
my $cursor_movement     = qr/\e\[[0-9]+[ABCD]/;
my $save_restore_cursor = qr/\e\[[su]/;
my $clear_screen        = qr/\e\[2J/;
my $erase_line          = qr/\e\[K/;
my $graphics_mode       = qr/\e\[[0-9]+(;[0-9]+)*m/;
my $ansi_code           = qr/
                            (
                              $cursor_position
                            | $cursor_movement
                            | $save_restore_cursor
                            | $clear_screen
                            | $erase_line
                            | $graphics_mode
                            )
                            /x;

                            

sub tty_length
{
    my $string = shift;
    return length(remove_ansi_codes($string));
}

sub tty_width
{
    my $string = shift;
    $string = remove_ansi_codes($string);

    my $width = eval { Text::CharWidth::mbswidth($string) };
    $width = length($string) if not defined $width;

    return $width;
}

# might make this an exportable function
# as well, but not sure what the right name is :-)
sub remove_ansi_codes
{
    my $string = shift;
    $string =~ s/$ansi_code//mosg;
    return $string;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

String::TtyLength - length or width of string excluding ANSI tty codes

=head1 SYNOPSIS

 use Text::Table::Tiny / tty_length /;
 $length = tty_length("\e[1mbold text\e[0m");
 print "length = $length\n";

 # 9

=head1 DESCRIPTION

This module provides two functions which tell you the length
and width of a string as it will appear on a terminal (tty),
excluding any ANSI escape codes.

C<tty_length> returns the length of a string excluding any ANSI
tty / terminal escape codes.

C<tty_width> returns the number of columns on a terminal that
the string will take up, also excluding any escape codes.

For non-wide characters, they functions will return the same value.
But consider the following:

 my $emoji  = "😄";
 my $length = tty_length($emoji);   # 1
 my $width  = tty_width($emoji);    # 2

If you're trying to align text in columns,
then you'll probably want C<tty_width>;
if you just want to know the number of characters,
using C<tty_length>.

=head2 tty_length( STRING )

Takes a single string,
and returns the length of the string,
excluding any escape sequences.

Note: the escape sequences could include cursor movement,
so the length returned by this function might not be the
number of characters that would be visible on screen.
But C<length_of_string_excluding_escape_sequences()>
was just too long.

=head2 tty_width( STRING )

Takes a single string and returns the number of columns
that the string will take up on a terminal.

If you might have wide characters in your string,
you should make sure you've installed L<Text::CharWidth>,
as that's used to calculate the width,
after stripping any escape codes.
If you don't have C<Text::CharWidth> installed,
we fall back onto using the C<length()> builtin.

=head1 REPOSITORY

L<https://github.com/neilb/String-TtyLength>


=head1 AUTHOR

Neil Bowers <neilb@cpan.org>


=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Neil Bowers.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

