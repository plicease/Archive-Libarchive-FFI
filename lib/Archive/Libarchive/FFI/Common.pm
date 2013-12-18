package Archive::Libarchive::FFI::Common;

use strict;
use warnings;

# ABSTRACT: Libarchive private package
# VERSION

package
  Archive::Libarchive::FFI;

use Encode qw( encode decode );

sub archive_write_open_memory ($$)
{
  my($archive, $memory) = @_;
  archive_write_open($archive, $memory, undef, \&_archive_write_open_memory_write, undef);
}

sub _archive_write_open_memory_write
{
  my($archive, $data, $buffer) = @_;
  $$data .= $buffer;
  return length $buffer;
}

sub archive_read_open_fh ($$;$)
{
  my($archive, $fh, $bs) = @_;
  $bs ||= 10240;
  my $data = { bs => $bs, fh => $fh };
  archive_read_open($archive, $data, undef, \&_archive_read_open_fh_read, undef);
}

sub _archive_read_open_fh_read
{
  my($archive, $data) = @_;
  my $br = read $data->{fh}, my $buffer, $data->{bs};
  if(defined $br)
  {
    return (ARCHIVE_OK(), $buffer);
  }
  else
  {
    warn 'read error';
    return ARCHIVE_FAILED();
  }
}

sub archive_write_open_fh ($$)
{
  my($archive, $fh) = @_;
  my $data = { fh => $fh };
  archive_write_open($archive, $data, undef, \&_archive_write_open_fh_write, undef);
}

sub _archive_write_open_fh_write
{
  my($archive, $data, $buffer) = @_;
  my $bw = syswrite $data->{fh}, $buffer;
  if(defined $bw)
  {
    return $bw;
  }
  else
  {
    warn 'write error';
    return ARCHIVE_FATAL();
  }
}

# TODO: for XS version, implement this in XS
sub archive_entry_stat ($)
{
  my($entry) = @_;
  no strict 'refs';
  map { &{"archive_entry_$_"}($entry) } qw ( dev ino mode nlink uid gid rdev atime mtime ctime );
}

# TODO: for XS version, implement this in XS
sub archive_entry_set_stat
{
  my $entry = shift;
  my $status = ARCHIVE_OK();
  no strict 'refs';
  foreach my $prop (qw( dev ino mode nlink uid gid rdev ))
  {
    my $status2 = &{"archive_entry_set_$prop"}($entry, shift);
    $status = $status2 if $status2 < $status;
  }
  foreach my $prop (qw( atime mtime ctime ))
  {
    my $value = shift;
    my $status2 = &{"archive_entry_set_$prop"}($entry, $value, $value);
    $status = $status2 if $status2 < $status;
  }
  $status;
}

sub archive_read_data_into_fh
{
  my($archive, $fh) = @_;

  my $bw = 0;
  my $zero;

  while(1)
  {
    my $r = archive_read_data_block($archive, my $buff, my $offset);
    return ARCHIVE_OK() if $r == ARCHIVE_EOF();
    if($r == ARCHIVE_OK() || $r == ARCHIVE_WARN())
    {
      while($offset != $bw)
      {
        # TODO: this is slow do something a little less brain dead.
        print $fh "\0";
        $bw++;
      }
      $bw += length $buff;
      print $fh $buff;
    }
    else
    {
      return $r;
    }
  }
}

*archive_entry_copy_stat = \&archive_entry_set_stat
  if __PACKAGE__->can('archive_entry_set_stat');

*archive_entry_copy_sourcepath = \&archive_entry_set_sourcepath
  if __PACKAGE__->can('archive_entry_set_sourcepath');

*archive_entry_copy_fflags_text = \&archive_entry_set_fflags_text
  if __PACKAGE__->can('archive_entry_set_fflags_text');

sub _sub_if_can ($$)
{
  my($name,$coderef) = @_;
  if(__PACKAGE__->can("_$name"))
  {
    no strict 'refs';
    *{$name} = $coderef;
  }
}

_sub_if_can( archive_version_string => sub {
  decode(archive_perl_codeset(), _archive_version_string());
});
_sub_if_can( archive_format_name => sub {
  decode(archive_perl_codeset(), _archive_format_name($_[0]));
});
_sub_if_can( archive_error_string => sub {
  decode(archive_perl_codeset(), _archive_error_string($_[0]));
});
_sub_if_can( archive_read_open_filename => sub {
  _archive_read_open_filename($_[0], encode(archive_perl_codeset(), $_[1]), $_[2]);
});
_sub_if_can( archive_read_support_filter_program => sub {
  _archive_read_support_filter_program($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_read_set_filter_option => sub {
  _archive_read_set_filter_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]));
});
_sub_if_can( archive_read_set_format_option => sub {
  _archive_read_set_format_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]));
});
_sub_if_can( archive_read_set_option => sub {
  _archive_read_set_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]));
});
_sub_if_can( archive_read_set_options => sub {
  _archive_read_set_options($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_read_set_format => sub {
  _archive_read_set_format($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]));
});
_sub_if_can( archive_filter_name => sub {
  decode(archive_perl_codeset(), _archive_filter_name($_[0], $_[1]));
});
_sub_if_can( archive_write_add_filter_by_name => sub {
  _archive_write_add_filter_by_name($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_write_add_filter_program => sub {
  _archive_write_add_filter_program($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_read_support_filter_program_signature => sub {
  _archive_read_support_filter_program_signature($_[0], encode(archive_perl_codeset(), $_[1]), $_[2]);
});
_sub_if_can( archive_read_append_filter_program_signature => sub {
  _archive_read_append_filter_program_signature($_[0], encode(archive_perl_codeset(), $_[1]), $_[2]);
});
_sub_if_can( archive_write_set_format_by_name => sub {
  _archive_write_set_format_by_name($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_write_open_filename => sub {
  _archive_write_open_filename($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_write_set_filter_option => sub {
  _archive_write_set_filter_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]));
});
_sub_if_can( archive_write_set_format_option => sub {
  _archive_write_set_format_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]));
});
_sub_if_can( archive_write_set_option => sub {
  _archive_write_set_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]));
});
_sub_if_can( archive_write_set_options => sub {
  _archive_write_set_options($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_write_disk_gid => sub {
  _archive_write_disk_gid($_[0], encode(archive_perl_codeset(), $_[1]), $_[2]);
});
_sub_if_can( archive_write_disk_uid => sub {
  _archive_write_disk_uid($_[0], encode(archive_perl_codeset(), $_[1]), $_[2]);
});
_sub_if_can( archive_entry_fflags_text => sub {
  decode(archive_perl_codeset(), _archive_entry_fflags_text($_[0]));
});
_sub_if_can( archive_read_disk_open => sub {
  _archive_read_disk_open($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_read_disk_gname => sub {
  decode(archive_perl_codeset(), _archive_read_disk_gname($_[0], $_[1]));
});
_sub_if_can( archive_read_disk_uname => sub {
  decode(archive_perl_codeset(), _archive_read_disk_uname($_[0], $_[1]));
});
_sub_if_can( archive_entry_acl_add_entry => sub {
  _archive_entry_acl_add_entry($_[0], $_[1], $_[2], $_[3], $_[4], encode(archive_perl_codeset(), $_[5]));
});
_sub_if_can( archive_entry_acl_text => sub {
  decode(archive_perl_codeset(), _archive_entry_acl_text($_[0], $_[1]));
});
_sub_if_can( archive_match_include_uname => sub {
  _archive_match_include_uname($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_match_include_gname => sub {
  _archive_match_include_gname($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_entry_set_sourcepath => sub {
  _archive_entry_set_sourcepath($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_entry_sourcepath => sub {
  decode(archive_perl_codeset(), _archive_entry_sourcepath($_[0]));
});
_sub_if_can( archive_entry_set_fflags_text => sub {
  _archive_entry_set_fflags_text($_[0], encode(archive_perl_codeset(), $_[1]));
});
_sub_if_can( archive_entry_set_link => sub {
  _archive_entry_set_link($_[0], encode(archive_perl_codeset(), $_[1]));
});

1;

=head1 SEE ALSO

=over 4

=item L<Archive::Libarchive::FFI>

=back

=cut
