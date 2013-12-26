package Archive::Libarchive::FFI;

use strict;
use warnings;
use Alien::Libarchive;
use I18N::Langinfo ();
use Exporter::Tidy ();
use Encode ();
use Carp qw( croak );
use FFI::Raw ();
use FFI::Sweet;
use FFI::Util qw(
  deref_ptr_get
  deref_uint64_get
  deref_uint_get
  deref_ulong_get
  deref_int64_get
  deref_size_t_get
  buffer_to_scalar
  scalar_to_buffer
  deref_int_get
  deref_str_get
  :types
);

# ABSTRACT: Perl bindings to libarchive via FFI
# VERSION

ffi_lib(Alien::Libarchive->new);

require Archive::Libarchive::FFI::Constant;
require Archive::Libarchive::FFI::Callback;

$Archive::Libarchive::FFI::on_attach ||= sub {};

sub _attach ($$$)
{
  $Archive::Libarchive::FFI::on_attach->(@_);
  my($name, $arg, $ret) = @_;
  $name = [ $name => "_$name" ] if grep { $_ == FFI::Raw::str } ($ret, @$arg);
  if($ret == _void)
  {
    attach_function $name, $arg, $ret, sub {
      my $code = shift;
      $code->(@_);
      ARCHIVE_OK();
    };
  }
  else
  {
    attach_function $name, $arg, $ret;
  }
}

_attach 'archive_version_number',                        undef, _int;
_attach 'archive_version_string',                        undef, _str;
_attach 'archive_clear_error',                           [ _ptr ], _void;
_attach 'archive_copy_error',                            [ _ptr ], _int;
_attach 'archive_errno',                                 [ _ptr ], _int;
_attach 'archive_file_count',                            [ _ptr ], _int;
_attach 'archive_format',                                [ _ptr ], _int;
_attach 'archive_format_name',                           [ _ptr ], _str;
_attach 'archive_seek_data',                             [ _ptr, _int64, _int ], _int64;
_attach 'archive_error_string',                          [ _ptr ], _str;

_attach 'archive_read_new',                              undef, _ptr;
_attach 'archive_read_support_filter_all',               [ _ptr ], _int;
_attach 'archive_read_support_format_all',               [ _ptr ], _int;
_attach 'archive_read_open1',                            [ _ptr ], _int;
_attach 'archive_read_open_filename',                    [ _ptr, _str, _int ], _int;
_attach 'archive_read_data_skip',                        [ _ptr ], _int;
_attach 'archive_read_close',                            [ _ptr ], _int;
_attach 'archive_read_append_filter',                    [ _ptr, _int ], _int;
_attach 'archive_read_append_filter_program',            [ _ptr, _str ], _int;
_attach 'archive_read_support_filter_program',           [ _ptr, _str ], _int;
_attach 'archive_read_support_format_by_code',           [ _ptr, _int ], _int;
_attach 'archive_read_header_position',                  [ _ptr ], _int64;
_attach 'archive_read_set_filter_option',                [ _ptr, _str, _str, _str ], _int;
_attach 'archive_read_set_format_option',                [ _ptr, _str, _str, _str ], _int;
_attach 'archive_read_set_option',                       [ _ptr, _str, _str, _str ], _int;
_attach 'archive_read_set_options',                      [ _ptr, _str ], _int;
_attach 'archive_read_set_format',                       [ _ptr, _str, _str, _str ], _int;
_attach 'archive_read_next_header2',                     [ _ptr, _ptr ], _int;
_attach 'archive_read_extract',                          [ _ptr, _ptr, _int ], _int;
_attach 'archive_read_extract2',                         [ _ptr, _ptr, _ptr ], _int;
_attach 'archive_read_extract_set_skip_file',            [ _ptr, _int64, _int64 ], _void;

_attach 'archive_filter_code',                           [ _ptr, _int ], _int;
_attach 'archive_filter_count',                          [ _ptr ], _int;
_attach 'archive_filter_name',                           [ _ptr, _int ], _str;
_attach 'archive_filter_bytes',                          [ _ptr, _int ], _int64;

_attach 'archive_write_new',                             undef, _ptr;
_attach 'archive_write_add_filter',                      [ _ptr, _int ], _int;
_attach 'archive_write_add_filter_by_name',              [ _ptr, _str ], _int;
_attach 'archive_write_add_filter_program',              [ _ptr, _str ], _int;
_attach 'archive_write_set_format',                      [ _ptr, _int ], _int;
_attach 'archive_write_set_format_by_name',              [ _ptr, _str ], _int;
_attach 'archive_write_open_filename',                   [ _ptr, _str ], _int;
_attach 'archive_write_header',                          [ _ptr, _ptr ], _int;
_attach 'archive_write_close',                           [ _ptr ], _int;
_attach 'archive_write_disk_new',                        undef, _ptr;
_attach 'archive_write_disk_set_options',                [ _ptr, _int ], _int;
_attach 'archive_write_finish_entry',                    [ _ptr ], _int;
_attach 'archive_write_disk_set_standard_lookup',        [ _ptr ], _int;
_attach 'archive_write_zip_set_compression_deflate',     [ _ptr ], _int;
_attach 'archive_write_zip_set_compression_store',       [ _ptr ], _int;
_attach 'archive_write_set_filter_option',               [ _ptr, _str, _str, _str ], _int;
_attach 'archive_write_set_format_option',               [ _ptr, _str, _str, _str ], _int;
_attach 'archive_write_set_option',                      [ _ptr, _str, _str, _str ], _int;
_attach 'archive_write_set_options',                     [ _ptr, _str ], _int;
_attach 'archive_write_set_skip_file',                   [ _ptr, _int64, _int64 ], _int;
_attach 'archive_write_disk_gid',                        [ _ptr, _str, _int64 ], _int64;
_attach 'archive_write_disk_set_skip_file',              [ _ptr, _int64, _int64 ], _int;
_attach 'archive_write_disk_uid',                        [ _ptr, _str, _int64 ], _int64;
_attach 'archive_write_fail',                            [ _ptr ], _int;
_attach 'archive_write_get_bytes_in_last_block',         [ _ptr ], _int;
_attach 'archive_write_get_bytes_per_block',             [ _ptr ], _int;
_attach 'archive_write_set_bytes_in_last_block',         [ _ptr, _int ], _int;
_attach 'archive_write_set_bytes_per_block',             [ _ptr, _int ], _int;

_attach 'archive_entry_clear',                           [ _ptr ], _void;
_attach 'archive_entry_clone',                           [ _ptr ], _ptr;
_attach 'archive_entry_free',                            [ _ptr ], _void;
_attach 'archive_entry_new',                             undef, _ptr;
_attach 'archive_entry_new2',                            [ _ptr ], _ptr;
_attach 'archive_entry_size',                            [ _ptr ], _int64;
_attach 'archive_entry_set_size',                        [ _ptr, _int64 ], _void;
_attach 'archive_entry_set_perm',                        [ _ptr, _int ], _void;
_attach 'archive_entry_set_filetype',                    [ _ptr, _int ], _void;
_attach 'archive_entry_set_mtime',                       [ _ptr, _time_t, _long ], _void; 
_attach 'archive_entry_set_ctime',                       [ _ptr, _time_t, _long ], _void;
_attach 'archive_entry_set_atime',                       [ _ptr, _time_t, _long ], _void;
_attach 'archive_entry_atime_is_set',                    [ _ptr ], _int;
_attach 'archive_entry_atime',                           [ _ptr ], _time_t;
_attach 'archive_entry_atime_nsec',                      [ _ptr ], _long;
_attach 'archive_entry_birthtime_is_set',                [ _ptr ], _int;
_attach 'archive_entry_birthtime',                       [ _ptr ], _time_t;
_attach 'archive_entry_birthtime_nsec',                  [ _ptr ], _long;
_attach 'archive_entry_ctime_is_set',                    [ _ptr ], _int;
_attach 'archive_entry_ctime',                           [ _ptr ], _time_t;
_attach 'archive_entry_ctime_nsec',                      [ _ptr ], _long;
_attach 'archive_entry_mtime_is_set',                    [ _ptr ], _int;
_attach 'archive_entry_mtime',                           [ _ptr ], _time_t;
_attach 'archive_entry_mtime_nsec',                      [ _ptr ], _long;
_attach 'archive_entry_dev_is_set',                      [ _ptr ], _int;
_attach 'archive_entry_dev',                             [ _ptr ], _dev_t;
_attach 'archive_entry_devmajor',                        [ _ptr ], _dev_t;
_attach 'archive_entry_devminor',                        [ _ptr ], _dev_t;
_attach 'archive_entry_fflags_text',                     [ _ptr ], _str;
_attach 'archive_entry_gid',                             [ _ptr ], _gid_t;
_attach 'archive_entry_rdev',                            [ _ptr ], _int64;
_attach 'archive_entry_rdevmajor',                       [ _ptr ], _int64;
_attach 'archive_entry_rdevminor',                       [ _ptr ], _int64;
_attach 'archive_entry_set_rdev',                        [ _ptr, _int64 ], _void;
_attach 'archive_entry_set_rdevmajor',                   [ _ptr, _int64 ], _void;
_attach 'archive_entry_set_rdevminor',                   [ _ptr, _int64 ], _void;
_attach 'archive_entry_filetype',                        [ _ptr ], _int;
_attach 'archive_entry_ino',                             [ _ptr ], _int64;
_attach 'archive_entry_ino_is_set',                      [ _ptr ], _int;
_attach 'archive_entry_mode',                            [ _ptr ], _int;
_attach 'archive_entry_nlink',                           [ _ptr ], _uint;
_attach 'archive_entry_perm',                            [ _ptr ], _int;
_attach 'archive_entry_set_dev',                         [ _ptr, _dev_t ], _void;
_attach 'archive_entry_set_devmajor',                    [ _ptr, _dev_t ], _void;
_attach 'archive_entry_set_devminor',                    [ _ptr, _dev_t ], _void;
_attach 'archive_entry_set_fflags',                      [ _ptr, _ulong, _ulong ], _void;
_attach 'archive_entry_set_gid',                         [ _ptr, _gid_t ], _void;
_attach 'archive_entry_set_ino',                         [ _ptr, _int64 ], _void;
_attach 'archive_entry_set_link',                        [ _ptr, _str ], _void;
_attach 'archive_entry_set_mode',                        [ _ptr, _int ], _void;
_attach 'archive_entry_set_nlink',                       [ _ptr, _int ], _void;
_attach 'archive_entry_set_uid',                         [ _ptr, _int64 ], _void;
_attach 'archive_entry_size_is_set',                     [ _ptr ], _int;
_attach 'archive_entry_unset_atime',                     [ _ptr ], _void;
_attach 'archive_entry_unset_birthtime',                 [ _ptr ], _void;
_attach 'archive_entry_unset_ctime',                     [ _ptr ], _void;
_attach 'archive_entry_unset_mtime',                     [ _ptr ], _void;
_attach 'archive_entry_unset_size',                      [ _ptr ], _void;
_attach 'archive_entry_xattr_clear',                     [ _ptr ], _void;
_attach 'archive_entry_xattr_count',                     [ _ptr ], _int;
_attach 'archive_entry_xattr_reset',                     [ _ptr ], _int;
_attach 'archive_entry_uid',                             [ _ptr ], _uid_t;
_attach 'archive_entry_copy_sourcepath',                 [ _ptr, _str ], _void;
_attach 'archive_entry_acl',                             [ _ptr ], _ptr;
_attach 'archive_entry_acl_clear',                       [ _ptr ], _int;
_attach 'archive_entry_acl_add_entry',                   [ _ptr, _int, _int, _int, _int, _str ], _int;
_attach 'archive_entry_acl_reset',                       [ _ptr, _int ], _int;
_attach 'archive_entry_acl_text',                        [ _ptr, _int ], _str;
_attach 'archive_entry_acl_count',                       [ _ptr, _int ], _int;

_attach 'archive_entry_linkresolver_free',               [ _ptr ], _void;
_attach 'archive_entry_linkresolver_new',                undef, _ptr;
_attach 'archive_entry_linkresolver_set_strategy',       [ _ptr, _int ], _void;

_attach 'archive_read_disk_descend',                     [ _ptr ], _int;
_attach 'archive_read_disk_can_descend',                 [ _ptr ], _int;
_attach 'archive_read_disk_current_filesystem',          [ _ptr ], _int;
_attach 'archive_read_disk_current_filesystem_is_synthetic', [ _ptr ], _int;
_attach 'archive_read_disk_current_filesystem_is_remote', [ _ptr ], _int;
_attach 'archive_read_disk_set_atime_restored',          [ _ptr ], _int;
_attach 'archive_read_disk_open',                        [ _ptr, _str ], _int;
_attach 'archive_read_disk_gname',                       [ _ptr, _int64 ], _str;
_attach 'archive_read_disk_uname',                       [ _ptr, _int64 ], _str;
_attach 'archive_read_disk_new',                         undef, _ptr;
_attach 'archive_read_disk_set_behavior',                [ _ptr, _int ], _int;
_attach 'archive_read_disk_set_standard_lookup',         [ _ptr ], _int;
_attach 'archive_read_disk_set_symlink_hybrid',          [ _ptr ], _int;
_attach 'archive_read_disk_set_symlink_logical',         [ _ptr ], _int;
_attach 'archive_read_disk_set_symlink_physical',        [ _ptr ], _int;

_attach 'archive_match_new',                             undef, _ptr;
_attach 'archive_match_free',                            [ _ptr ], _int;
_attach 'archive_match_excluded',                        [ _ptr, _ptr ], _int;
_attach 'archive_match_path_excluded',                   [ _ptr, _ptr ], _int;
_attach 'archive_match_time_excluded',                   [ _ptr, _ptr ], _int;
_attach 'archive_match_owner_excluded',                  [ _ptr, _ptr ], _int;
_attach 'archive_match_include_gid',                     [ _ptr, _gid_t ], _int;
_attach 'archive_match_include_uid',                     [ _ptr, _uid_t ], _int;
_attach 'archive_match_include_gname',                   [ _ptr, _str ], _int;
_attach 'archive_match_include_uname',                   [ _ptr, _str ], _int;

_attach "archive_read_support_filter_$_",  [ _ptr ], _int
  for qw( bzip2 compress gzip grzip lrzip lzip lzma lzop none rpm uu xz );
_attach "archive_read_support_format_$_",  [ _ptr ], _int
  for qw( 7zip ar cab cpio empty gnutar iso9660 lha mtree rar raw tar xar zip );
_attach "archive_write_add_filter_$_", [ _ptr ], _int
  for qw( b64encode bzip2 compress grzip gzip lrzip lzip lzma lzop none uuencode xz );
_attach "archive_write_set_format_$_", [ _ptr ], _int
  for qw( 7zip ar_bsd ar_svr4 cpio cpio_newc gnutar iso9660 mtree mtree_classic 
          pax pax_restricted shar shar_dump ustar v7tar xar zip);

attach_function 'archive_entry_fflags', [ _ptr, _ptr, _ptr ], _void, sub
{
  my $set   = FFI::Raw::MemPtr->new_from_ptr(0);
  my $clear = FFI::Raw::MemPtr->new_from_ptr(0);
  $_[0]->($_[1], $set, $clear);
  $_[2] = deref_ulong_get($$set);
  $_[3] = deref_ulong_get($$clear);
  return ARCHIVE_OK();
};

attach_function 'archive_read_next_header', [ _ptr, _ptr ], _int, sub
{
  my $entry = FFI::Raw::MemPtr->new_from_ptr(0);
  my $ret = $_[0]->($_[1], $entry);
  $_[2] = deref_ptr_get($$entry);
  $ret;
};

attach_function 'archive_read_data', [ _ptr, _ptr, _size_t ], _int, sub
{
  # 0 cb 1 archive 2 buffer 3 size
  my $buffer = FFI::Raw::MemPtr->new($_[3]);
  my $ret = $_[0]->($_[1], $buffer, $_[3]);
  $_[2] = $buffer->tostr($ret);
  $ret;
};

attach_function 'archive_read_data_block', [ _ptr, _ptr, _ptr, _ptr ], _int, sub
{
  # 0 cb 1 archive 2 buffer 3 offset
  my $buffer = FFI::Raw::MemPtr->new_from_ptr(0);
  my $size   = FFI::Raw::MemPtr->new_from_ptr(0);
  my $offset = FFI::Raw::MemPtr->new_from_ptr(0);
  my $ret    = $_[0]->($_[1], $buffer, $size, $offset);
  $size   = deref_size_t_get($size);
  $offset = deref_uint64_get($offset);
  $_[2]   = buffer_to_scalar(deref_ptr_get($$buffer), $size);
  $_[3]   = $offset;
  $ret;
};

attach_function 'archive_entry_acl_next', [ _ptr, _int, _ptr, _ptr, _ptr, _ptr, _ptr ], _int, sub
{
  # 0 cb 1 entry 2 want_type
  my $type    = FFI::Raw::MemPtr->new_from_ptr(0); # 3
  my $permset = FFI::Raw::MemPtr->new_from_ptr(0); # 4
  my $tag     = FFI::Raw::MemPtr->new_from_ptr(0); # 5
  my $qual    = FFI::Raw::MemPtr->new_from_ptr(0); # 6
  my $name    = FFI::Raw::MemPtr->new_from_ptr(0); # 7
  my $ret = $_[0]->($_[1], $_[2], $type, $permset, $tag, $qual, $name);
  $_[3] = deref_int_get($type);
  $_[4] = deref_int_get($permset);
  $_[5] = deref_int_get($tag);
  $_[6] = deref_int_get($qual);
  $_[7] = deref_str_get($name);
  $ret;
};

attach_function 'archive_write_data', [ _ptr, _ptr, _size_t ], _int, sub 
{
  my($cb, $archive, $buffer) = @_;
  my $size = do { use bytes; length($buffer) };
  my $ptr = FFI::Raw::MemPtr->new_from_buf($buffer, $size);
  $cb->($archive, $ptr, $size);
};

attach_function 'archive_write_data_block', [ _ptr, _ptr, _size_t, _int64 ], _int, sub
{
  my($cb, $archive, $buffer, $offset) = @_;
  my $size = do { use bytes; length($buffer) };
  my $ptr = FFI::Raw::MemPtr->new_from_buf($buffer, $size);
  $cb->($archive, $ptr, $size, $offset);
};

foreach my $name (qw( gname hardlink pathname symlink uname ))
{
  attach_function "archive_entry_$name", [ _ptr ], _str, sub
  {
    my($cb, $entry) = @_;
    _decode($cb->($entry));
  };
  attach_function [ "archive_entry_update_$name\_utf8" => "archive_entry_set_$name"], [ _ptr, _str ], _void, sub
  {
    my($cb, $entry, $name) = @_;
    $cb->($entry, defined $name ? Encode::encode('UTF-8', $name) : $name);
    ARCHIVE_OK();
  };
}

attach_function 'archive_read_open_filenames', [ _ptr, _ptr, _size_t ], _int, sub
{
  my($cb, $archive, $filenames, $bs) = @_;
  croak 'archive_read_open_filename: third argument must be array reference' unless ref($filenames) eq 'ARRAY';
  my @filenames = map { Encode::encode(archive_perl_codeset(), $_) } @$filenames;
  my $ptr = pack( ('P' x @filenames).'L!', @filenames, 0);
  $ptr = FFI::Raw::MemPtr->new_from_buf($ptr, length $ptr);
  $cb->($archive, $ptr, $bs);
};

attach_function [ 'archive_entry_copy_mac_metadata' => 'archive_entry_set_mac_metadata' ], [ _ptr, _ptr, _size_t ], _void, sub
{
  my($cb, $archive, $buffer) = @_;
  my($ptr, $size) = scalar_to_buffer($buffer);
  $cb->($archive, $ptr, $size);
  ARCHIVE_OK();
};

attach_function 'archive_entry_xattr_add_entry', [ _ptr, _str, _ptr, _size_t ], _void, sub
{
  my($cb, $entry, $name, $value) = @_;
  my($ptr, $size) = scalar_to_buffer($value);
  $cb->($entry, $name, $ptr, $size);
  ARCHIVE_OK();
};

attach_function 'archive_entry_xattr_next', [ _ptr, _ptr, _ptr, _ptr ], _int, sub
{
  my $name = FFI::Raw::MemPtr->new_from_ptr(0);
  my $ptr  = FFI::Raw::MemPtr->new_from_ptr(0);
  my $size = FFI::Raw::MemPtr->new_from_ptr(0);
  
  my $ret = $_[0]->($_[1], $name, $ptr, $size);
  $_[2] = deref_str_get($$name);
  $_[3] = buffer_to_scalar(deref_ptr_get($$ptr), deref_int64_get($$size));
  
  $ret;
};

do { no warnings 'once'; *archive_entry_copy_mac_metadata = \&archive_entry_set_mac_metadata };

attach_function 'archive_entry_mac_metadata', [ _ptr, _ptr ], _ptr, sub
{
  my($cb, $archive) = @_;
  my $size = FFI::Raw::MemPtr->new_from_ptr(0);
  my $ptr = $cb->($archive, $size);
  my $buffer = buffer_to_scalar($ptr, deref_uint64_get($$size));
};

attach_function 'archive_set_error', [ _ptr, _int, _str, _str ], _void, sub
{
  my($cb, $archive, $status, $format, @args) = @_;
  $cb->($archive, $status, "%s", sprintf($format, @args));
  ARCHIVE_OK();
};

attach_function [ 'archive_entry_copy_sourcepath' => '_archive_entry_set_sourcepath' ], [ _ptr, _str ], _void, sub
{
  my($cb, $entry, $string) = @_;
  $cb->($entry, $string);
  ARCHIVE_OK();
};

attach_function [ 'archive_entry_sourcepath' => '_archive_entry_sourcepath' ], [ _ptr ], _str;

attach_function $_, [ _ptr, _str, _ptr, _size_t ],_int, sub
{
  my($cb, $archive, $command, $signature) = @_;
  $cb->($archive, $command, scalar_to_buffer($signature));
} for qw( archive_read_append_filter_program_signature archive_read_support_filter_program_signature );

# this is an unusual one which doesn't need to be decoded
# because it should always be ASCII
attach_function 'archive_entry_strmode',                 [ _ptr ], _str;

attach_function 'archive_entry_linkify', [ _ptr, _ptr, _ptr ], _void, sub
{
  my($cb, $lr) = @_;
  my $ptr1 = FFI::Raw::MemPtr->new_from_ptr($_[2]);
  my $ptr2 = FFI::Raw::MemPtr->new_from_ptr($_[3]);
  $cb->($lr, $ptr1, $ptr2);
  $_[2] = deref_ptr_get($ptr1);
  $_[3] = deref_ptr_get($ptr2);
  ARCHIVE_OK();
};

attach_function [ 'archive_entry_copy_fflags_text' => '_archive_entry_set_fflags_text' ], [ _ptr, _str ], _void, sub
{
  shift->(@_);
  ARCHIVE_OK();
};

attach_function 'archive_read_disk_entry_from_file', [ _ptr, _ptr, _int, _ptr ], _int, sub
{
  my($cb, $archive, $entry, $fh, $stat) = @_;
  croak "stat field currently not supported"
    if defined $stat;
  my $fd = fileno $fh;
  $fd = -1 unless defined $fd;
  $cb->($archive, $entry, $fd, 0);
};

sub archive_perl_codeset
{
  I18N::Langinfo::langinfo(I18N::Langinfo::CODESET);
}

sub archive_perl_utf8_mode
{
  int(I18N::Langinfo::langinfo(I18N::Langinfo::CODESET) eq 'UTF-8');
}

require Archive::Libarchive::FFI::Common;

eval q{
  use Exporter::Tidy
    func  => [grep /^archive_/,       keys %Archive::Libarchive::FFI::],
    const => [grep /^(AE_|ARCHIVE_)/, keys %Archive::Libarchive::FFI::];
}; die $@ if $@;

1;

__END__

=head1 SYNOPSIS

list archive filenames

 use Archive::Libarchive::FFI qw( :all );
 
 my $archive = archive_read_new();
 archive_read_support_filter_all($archive);
 archive_read_support_format_all($archive);
 # example is a tar file, but any supported format should work
 # (zip, iso9660, etc.)
 archive_read_open_filename($archive, 'archive.tar', 10240);
 
 while(archive_read_next_header($archive, my $entry) == ARCHIVE_OK)
 {
   print archive_entry_pathname($entry), "\n";
   archive_read_data_skip($archive);
 }
 
 archive_read_free($archive);

extract archive

 use Archive::Libarchive::FFI qw( :all );
 
 my $archive = archive_read_new();
 archive_read_support_filter_all($archive);
 archive_read_support_format_all($archive);
 my $disk = archive_write_disk_new();
 archive_write_disk_set_options($disk, 
   ARCHIVE_EXTRACT_TIME   |
   ARCHIVE_EXTRACT_PERM   |
   ARCHIVE_EXTRACT_ACL    |
   ARCHIVE_EXTRACT_FFLAGS
 );
 archive_write_disk_set_standard_lookup($disk);
 archive_read_open_filename($archive, 'archive.tar', 10240);
 
 while(1)
 {
   my $r = archive_read_next_header($archive, my $entry);
   last if $r == ARCHIVE_EOF;
   
   archive_write_header($disk, $entry);
   
   while(1)
   {
     my $r = archive_read_data_block($archive, my $buffer, my $offset);
     last if $r == ARCHIVE_EOF;
     archive_write_data_block($disk, $buffer, $offset);
   }
 }
 
 archive_read_close($archive);
 archive_read_free($archive);
 archive_write_close($disk);
 archive_write_free($disk);

write archive

 use File::stat;
 use File::Slurp qw( read_file );
 use Archive::Libarchive::FFI qw( :all );
 
 my $archive = archive_write_new();
 # many other formats are supported ...
 archive_write_set_format_pax_restricted($archive);
 archive_write_open_filename($archive, 'archive.tar');
 
 foreach my $filename (@filenames)
 {
   my $entry = archive_entry_new();
   archive_entry_set_pathname($entry, $filename);
   archive_entry_set_size($entry, stat($filename)->size);
   archive_entry_set_filetype($entry, AE_IFREG);
   archive_entry_set_perm($entry, 0644);
   archive_write_header($archive, $entry);
   archive_write_data($archive, scalar read_file($filename));
   archive_entry_free($entry);
 }
 archive_write_close($archive);
 archive_write_free($archive);

=head1 DESCRIPTION

This module provides a functional interface to libarchive.  libarchive is a
C library that can read and write archives in a variety of formats and with a 
variety of compression filters, optimized in a stream oriented way.  A familiarity
with the libarchive documentation would be helpful, but may not be necessary
for simple tasks.  The documentation for this module is split into four separate
documents:

=over 4

=item L<Archive::Libarchive::FFI>

This document, contains an overview and some examples.

=item L<Archive::Libarchive::FFI::Callback>

Documents the callback interface, used for customizing input and output.

=item L<Archive::Libarchive::FFI::Constant>

Documents the constants provided by this module.

=item L<Archive::Libarchive::FFI::Function>

The function reference, includes a list of all functions provided by this module.

=back

If you are linking against an older version of libarchive, some functions
and constants may not be available.  You can use the C<can> method to test if
a function or constant is available, for example:

 if(Archive::Libarchive::FFI->can('archive_read_support_filter_grzip')
 {
   # grzip filter is available.
 }
 
 if(Archive::Libarchive::FFI->can('ARCHIVE_OK'))
 {
   # ... although ARCHIVE_OK should always be available.
 }

=head1 EXAMPLES

These examples are translated from equivalent C versions provided on the
libarchive website, and are annotated here with Perl specific details.
These examples are also included with the distribution.

=head2 List contents of archive stored in file

# EXAMPLE: example/list_contents_of_archive_stored_in_file.pl

=head2 List contents of archive stored in memory

# EXAMPLE: example/list_contents_of_archive_stored_in_memory.pl

=head2 List contents of archive with custom read functions

# EXAMPLE: example/list_contents_of_archive_with_custom_read_functions.pl

=head2 A universal decompressor

# EXAMPLE: example/universal_decompressor.pl

=head2 A basic write example

# EXAMPLE: example/basic_write.pl

=head2 Constructing objects on disk

# EXAMPLE: example/constructing_objects_on_disk.pl

=head2 A complete extractor

# EXAMPLE: example/complete_extractor.pl

=head2 Unicode

Libarchive deals with two types of string like data.  Pathnames, user and
group names are proper strings and are encoded in the codeset for the
current POSIX locale.  Content data for files stored and retrieved from in
raw bytes.

The usual operational procedure in Perl is to convert everything on input
into UTF-8, operate on the UTF-8 data and then convert (if necessary) 
everything on output to the desired output format.

In order to get useful string data out of libarchive, this module translates
its input/output using the codeset for the current POSIX locale.  So you must
be using a POSIX locale that supports the characters in the pathnames of
the archives you are going to process, and it is highly recommend that you
use a UTF-8 locale, which should cover everything.

 use strict;
 use warnings;
 use utf8;
 use Archive::Libarchive::FFI qw( :all );
 use POSIX qw( setlocale LC_ALL );
 
 # substitute en_US.utf8 for the correct UTF-8 locale for your region.
 setlocale(LC_ALL, "en_US.utf8"); # or 'export LANG=en_US.utf8' from your shell.
 
 my $entry = archive_entry_new();
 
 archive_entry_set_pathname($entry, "привет.txt");
 my $string = archive_entry_pathname($entry); # "привет.txt"
 
 archive_entry_free($entry);

If you try to pass a string with characters unsupported by your
current locale, the behavior is undefined.  If you try to retrieve
strings with characters unsupported by your current locale you will
get C<undef>.

Unfortunately locale names are not portable across systems, so you should
probably not hard code the locale as shown here unless you know the correct
locale name for all the platforms that your script will run.

There are two Perl only functions that give information about the
current codeset as understood by libarchive.
L<archive_perl_utf8_mode|Archive::Libarchive::FFI::Function#archive_perl_utf8_mode>
if the currently selected codeset is UTF-8.

 use strict;
 use warnings;
 use Archive::Libarchive::FFI qw( :all );
 
 die "must use UTF-8 locale" unless archive_perl_utf8_mode();

L<archive_perl_codeset|Archive::Libarchive::FFI::Function#archive_perl_codeset>
returns the currently selected codeset.

 use strict;
 use warnings;
 use Archive::Libarchive::FFI qw( :all );
 
 my $entry = archive_entry_new();
 
 if(archive_perl_codeset() =~ /^(ISO-8859-5|CP1251|KOI8-R|UTF-8)$/)
 {
   archive_entry_set_pathname($entry, "привет.txt");
   my $string = archive_entry_pathname($entry); # "привет.txt"
 }
 else
 {
   archive_entry_set_pathname($entry, "privet.txt");
   my $string = archive_entry_pathname($entry); # "privet.txt"
 }

Because libarchive reads and writes file content within an archive using
raw bytes, if your file content has non ASCII characters in it, then
you need to encode them

 use Encode qw( encode );
 
 archive_write_data($archive, encode('UTF-8', "привет.txt");
 # or
 archive_write_data($archive, encode('KOI8-R', "привет.txt"); 

read:

 use Encode qw( decode );
 
 my $raw;
 archive_read_data($archive, $raw, 10240);
 my $decoded_content = decode('UTF-8', $raw);
 # or
 my $decoded_content = decode('KOI8-R', $raw);

=head1 CAVEATS

Archive and entry objects are really pointers to opaque C structures
and need to be freed using one of 
L<archive_read_free|Archive::Libarchive::FFI::Function#archive_read_free>, 
L<archive_write_free|Archive::Libarchive::FFI::Function#archive_write_free> or 
L<archive_entry_free|Archive::Libarchive::FFI::Function#archive_entry_free>, 
in order to free the resources associated with those objects.

Proper Unicode (or non-ASCII character support) depends on setting the
correct POSIX locale, which is system dependent.

The documentation that comes with libarchive is not that great (by its own
admission), being somewhat incomplete, and containing a few subtle errors.
In writing the documentation for this distribution, I borrowed heavily (read:
stole wholesale) from the libarchive documentation, making changes where 
appropriate for use under Perl (changing C<NULL> to C<undef> for example, along 
with the interface change to make that work).  I may and probably have introduced 
additional subtle errors.  Patches to the documentation that match the
implementation, or fixes to the implementation so that it matches the
documentation (which ever is appropriate) would greatly appreciated.

=cut
