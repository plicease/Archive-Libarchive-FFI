# Archive::Libarchive::FFI

Perl bindings to libarchive via FFI

# SYNOPSIS

    use Archive::Libarchive::FFI;

# DESCRIPTION

This module provides a functional interface to `libarchive`.  `libarchive` is a
C library that can read and write archives in a variety of formats and with a 
variety of compression filters, optimized in a stream oriented way.  A familiarity
with the `libarchive` documentation would be helpful, but may not be necessary
for simple tasks.

# FUNCTIONS

Unless otherwise specified, each function will return an integer return code,
with one of the following values:

- ARCHIVE\_OK

    Operation was successful

- ARCHIVE\_EOF

    Fond end of archive

- ARCHIVE\_RETRY

    Retry might succeed

- ARCHIVE\_WARN

    Partial success

- ARCHIVE\_FAILED

    Current operation cannot complete

- ARCHIVE\_FATAL

    No more operations are possible

If you are linking against an older version of libarchive, some of these 
functions may not be available.  You can use the `can` method to test if
a function or constant is available, for example:

    if(Archive::Libarchive::FFI->can('archive_read_support_filter_grzip')
    {
      # grzip filter is available.
    }

You can use this one-liner to determine which functions and constants
are unavailable:

    % perl -MArchive::Libarchive::FFI    -E 'for(@Archive::Libarchive::FFI::EXPORT_OK) { say $_ unless Archive::Libarchive::FFI->can($_) }'

## archive\_clear\_error($archive)

Clears any error information left over from a previous call Not
generally used in client code.  Does not return a value.

## archive\_copy\_error($archive1, $archive2)

Copies error information from one archive to another.

## archive\_entry\_clear

Erases the object, resetting all internal fields to the same state as a newly-created object.  This is provided
to allow you to quickly recycle objects without thrashing the heap.

## archive\_entry\_clone

A deep copy operation; all text fields are duplicated.

## archive\_entry\_free

Releases the struct archive\_entry object.

## archive\_entry\_new

Allocate and return a blank struct archive\_entry object.

## archive\_entry\_new2

This form of `archive_entry_new2` will pull character-set
conversion information from the specified archive handle.  The
older `archive_entry_new` form will result in the use of an internal
default character-set conversion.

## archive\_entry\_pathname($entry)

Retrieve the pathname of the entry.

Returns a string value.

## archive\_entry\_set\_filetype($entry, $code)

Sets the filetype in the archive.  Code should be one of

- AE\_IFMT
- AE\_IFREG
- AE\_IFLNK
- AE\_IFSOCK
- AE\_IFCHR
- AE\_IFBLK
- AE\_IFDIR
- AE\_IFIFO

Does not return anything.

## archive\_entry\_set\_pathname($entry, $name)

Sets the path in the archive as a string.

Does not return anything.

## archive\_entry\_set\_perm

Set the permission bits for the entry.  This is the usual UNIX octal permission thing.

Does not return anything.

## archive\_entry\_set\_size($entry, $size)

Sets the size of the file in the archive.

Does not return anything.

FIXME: size is 64bit

## archive\_errno($archive)

Returns a numeric error code indicating the reason for the most
recent error return.

Return type is an errno integer value.

## archive\_error\_string($archive)

Returns a textual error message suitable for display.  The error
message here is usually more specific than that obtained from
passing the result of `archive_errno` to `strerror`.

Return type is a string.

## archive\_file\_count($archive)

Returns a count of the number of files processed by this archive object.  The count
is incremented by calls to `archive_write_header` or `archive_read_next_header`.

## archive\_filter\_code

Returns a numeric code identifying the indicated filter.  See `archive_filter_count`
for details of the numbering.

## archive\_filter\_count

Returns the number of filters in the current pipeline. For read archive handles, these 
filters are added automatically by the automatic format detection. For write archive 
handles, these filters are added by calls to the various `archive_write_add_filter_XXX`
functions. Filters in the resulting pipeline are numbered so that filter 0 is the filter 
closest to the format handler. As a convenience, functions that expect a filter number 
will accept -1 as a synonym for the highest-numbered filter. For example, when reading 
a uuencoded gzipped tar archive, there are three filters: filter 0 is the gunzip filter, 
filter 1 is the uudecode filter, and filter 2 is the pseudo-filter that wraps the archive 
read functions. In this case, requesting `archive_position(a,(-1))` would be a synonym
for `archive_position(a,(2))` which would return the number of bytes currently read from 
the archive, while `archive_position(a,(1))` would return the number of bytes after
uudecoding, and `archive_position(a,(0))` would return the number of bytes after decompression.

TODO: add bindings for archive\_position

## archive\_filter\_name

Returns a textual name identifying the indicated filter.  See [#archive_filter_count](https://metacpan.org/pod/#archive_filter_count) for
details of the numbering.

## archive\_format($archive)

Returns a numeric code indicating the format of the current archive
entry.  This value is set by a successful call to
`archive_read_next_header`.  Note that it is common for this value
to change from entry to entry.  For example, a tar archive might
have several entries that utilize GNU tar extensions and several
entries that do not.  These entries will have different format
codes.

## archive\_format\_name($archive)

A textual description of the format of the current entry.

## archive\_read\_data($archive, $buffer, $max\_size)

Read data associated with the header just read.  Internally, this is a
convenience function that calls `archive_read_data_block` and fills
any gaps with nulls so that callers see a single continuous stream of
data.  Returns the actual number of bytes read, 0 on end of data and
a negative value on error.

## archive\_read\_data\_skip($archive)

A convenience function that repeatedly calls `archive_read_data` to skip
all of the data for this archive entry.

## archive\_read\_free($archive)

Invokes `archive_read_close` if it was not invoked manually, then
release all resources.

## archive\_read\_new

Allocates and initializes a archive object suitable for reading from an archive.
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the read functions documented here with an <$archive> argument.

TODO: handle the unusual circumstance when this would return C NULL pointer.

## archive\_read\_next\_header($archive, $entry)

Read the header for the next entry and return an entry object
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the functions documented here with an <$entry> argument.

TODO: maybe use archive\_read\_next\_header2

## archive\_read\_open\_filename($archive, $filename, $block\_size)

Like `archive_read_open`, except that it accepts a simple filename
and a block size.  This function is safe for use with tape drives
or other blocked devices.

TODO: a NULL filename represents standard input.

## archive\_read\_open\_memory($archive, $buffer)

Like `archive_read_open`, except that it uses a Perl scalar that holds the 
content of the archive.  This function does not make a copy of the data stored 
in `$buffer`, so you should not modify the buffer until you have free the 
archive using `archive_read_free`.

Bad things will happen if the buffer falls out of scope and is deallocated
before you free the archive, so make sure that there is a reference to the
buffer somewhere in your programmer until `archive_read_free` is called.

## archive\_read\_support\_filter\_all($archive)

Enable all available decompression filters.

## archive\_read\_support\_filter\_bzip2($archive)

Enable bzip2 decompression filter.

## archive\_read\_support\_filter\_compress($archive)

Enable compress decompression filter.

## archive\_read\_support\_filter\_grzip($archive)

Enable grzip decompression filter.

## archive\_read\_support\_filter\_gzip($archive)

Enable gzip decompression filter.

## archive\_read\_support\_filter\_lrzip($archive)

Enable lrzip decompression filter.

## archive\_read\_support\_filter\_lzip($archive)

Enable lzip decompression filter.

## archive\_read\_support\_filter\_lzma($archive)

Enable lzma decompression filter.

## archive\_read\_support\_filter\_lzop($archive)

Enable lzop decompression filter.

## archive\_read\_support\_filter\_none($archive)

Enable none decompression filter.

## archive\_read\_support\_filter\_program(archive, command)

Data is feed through the specified external program before being
dearchived.  Note that this disables automatic detection of the
compression format, so it makes no sense to specify this in
conjunction with any other decompression option.

TODO: also support archive\_read\_support\_filter\_program\_signature

## archive\_read\_support\_format\_7zip($archive)

Enable 7zip archive format.

## archive\_read\_support\_format\_all($archive)

Enable all available archive formats.

## archive\_read\_support\_format\_ar($archive)

Enable ar archive format.

## archive\_read\_support\_format\_by\_code($archive, $code)

Enables a single format specified by the format code.

## archive\_read\_support\_format\_cab($archive)

Enable cab archive format.

## archive\_read\_support\_format\_cpio($archive)

Enable cpio archive format.

## archive\_read\_support\_format\_empty($archive)

Enable empty archive format.

## archive\_read\_support\_format\_gnutar($archive)

Enable gnutar archive format.

## archive\_read\_support\_format\_iso9660($archive)

Enable iso9660 archive format.

## archive\_read\_support\_format\_lha($archive)

Enable lha archive format.

## archive\_read\_support\_format\_mtree($archive)

Enable mtree archive format.

## archive\_read\_support\_format\_rar($archive)

Enable rar archive format.

## archive\_read\_support\_format\_raw($archive)

Enable raw archive format.

## archive\_read\_support\_format\_tar($archive)

Enable tar archive format.

## archive\_read\_support\_format\_xar($archive)

Enable xar archive format.

## archive\_read\_support\_format\_zip($archive)

Enable zip archive format.

## archive\_version\_number

Return the libarchive version as an integer.

## archive\_version\_string

Return the libarchive as a version.

Returns a string value.

## archive\_write\_add\_filter($archive, $code)

A convenience function to set the filter based on the code.

## archive\_write\_add\_filter\_b64encode($archive)

Add b64encode filter

## archive\_write\_add\_filter\_by\_name($archive, $name)

A convenience function to set the filter based on the name.

## archive\_write\_add\_filter\_bzip2($archive)

Add bzip2 filter

## archive\_write\_add\_filter\_compress($archive)

Add compress filter

## archive\_write\_add\_filter\_grzip($archive)

Add grzip filter

## archive\_write\_add\_filter\_gzip($archive)

Add gzip filter

## archive\_write\_add\_filter\_lrzip($archive)

Add lrzip filter

## archive\_write\_add\_filter\_lzip($archive)

Add lzip filter

## archive\_write\_add\_filter\_lzma($archive)

Add lzma filter

## archive\_write\_add\_filter\_lzop($archive)

Add lzop filter

## archive\_write\_add\_filter\_none($archive)

Add none filter

## archive\_write\_add\_filter\_program($archive, $cmd)

The archive will be fed into the specified compression program. 
The output of that program is blocked and written to the client
write callbacks.

## archive\_write\_add\_filter\_uuencode($archive)

Add uuencode filter

## archive\_write\_add\_filter\_xz($archive)

Add xz filter

## archive\_write\_close(archive)

Complete the archive and invoke the close callback.

## archive\_write\_data(archive, buffer)

Write data corresponding to the header just written.

This function returns the number of bytes actually written, or -1 on error.

## archive\_write\_free($archive)

Invokes `archive_write_close` if it was not invoked manually, then
release all resources.

## archive\_write\_header($archive, $entry)

Build and write a header using the data in the provided struct archive\_entry structure.
You can use `archive_entry_new` to create an `$entry` object and populate it with
`archive_entry_set*` functions.

## archive\_write\_new

Allocates and initializes a archive object suitable for writing an new archive.
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the functions write documented here with an <$archive> argument.

TODO: handle the unusual circumstance when this would return C NULL pointer.

## archive\_write\_open\_filename($archive, $filename)

A convenience form of `archive_write_open` that accepts a filename.  A NULL argument indicates that the output
should be written to standard output; an argument of "-" will open a file with that name.  If you have not
invoked `archive_write_set_bytes_in_last_block`, then `archive_write_open_filename` will adjust the last-block
padding depending on the file: it will enable padding when writing to standard output or to a character or block
device node, it will disable padding otherwise.  You can override this by manually invoking
`archive_write_set_bytes_in_last_block` before `calling archive_write_open`.  The `archive_write_open_filename`
function is safe for use with tape drives or other block-oriented devices.

TODO: How to pass NULL in?

## archive\_write\_set\_format($archive, $code)

A convenience function to set the format based on the code.

## archive\_write\_set\_format\_7zip($archive)

Set the archive format to 7zip

## archive\_write\_set\_format\_ar\_bsd($archive)

Set the archive format to ar\_bsd

## archive\_write\_set\_format\_ar\_svr4($archive)

Set the archive format to ar\_svr4

## archive\_write\_set\_format\_by\_name($archive, $name)

A convenience function to set the format based on the name.

## archive\_write\_set\_format\_cpio($archive)

Set the archive format to cpio

## archive\_write\_set\_format\_cpio\_newc($archive)

Set the archive format to cpio\_newc

## archive\_write\_set\_format\_gnutar($archive)

Set the archive format to gnutar

## archive\_write\_set\_format\_iso9660($archive)

Set the archive format to iso9660

## archive\_write\_set\_format\_mtree($archive)

Set the archive format to mtree

## archive\_write\_set\_format\_mtree\_classic($archive)

Set the archive format to mtree\_classic

## archive\_write\_set\_format\_pax($archive)

Set the archive format to pax

## archive\_write\_set\_format\_pax\_restricted($archive)

Set the archive format to pax\_restricted

## archive\_write\_set\_format\_shar($archive)

Set the archive format to shar

## archive\_write\_set\_format\_shar\_dump($archive)

Set the archive format to shar\_dump

## archive\_write\_set\_format\_ustar($archive)

Set the archive format to ustar

## archive\_write\_set\_format\_v7tar($archive)

Set the archive format to v7tar

## archive\_write\_set\_format\_xar($archive)

Set the archive format to xar

## archive\_write\_set\_format\_zip($archive)

Set the archive format to zip

# CONSTANTS

If provided by your libarchive library, these constants will be available and
exportable from the [Archive::Libarchive::FFI](https://metacpan.org/pod/Archive::Libarchive::FFI) (you may import all available
constants using the `:const` export tag).

- AE\_IFBLK
- AE\_IFCHR
- AE\_IFDIR
- AE\_IFIFO
- AE\_IFLNK
- AE\_IFMT
- AE\_IFREG
- AE\_IFSOCK
- ARCHIVE\_COMPRESSION\_BZIP2
- ARCHIVE\_COMPRESSION\_COMPRESS
- ARCHIVE\_COMPRESSION\_GZIP
- ARCHIVE\_COMPRESSION\_LRZIP
- ARCHIVE\_COMPRESSION\_LZIP
- ARCHIVE\_COMPRESSION\_LZMA
- ARCHIVE\_COMPRESSION\_NONE
- ARCHIVE\_COMPRESSION\_PROGRAM
- ARCHIVE\_COMPRESSION\_RPM
- ARCHIVE\_COMPRESSION\_UU
- ARCHIVE\_COMPRESSION\_XZ
- ARCHIVE\_ENTRY\_ACL\_ADD\_FILE
- ARCHIVE\_ENTRY\_ACL\_ADD\_SUBDIRECTORY
- ARCHIVE\_ENTRY\_ACL\_APPEND\_DATA
- ARCHIVE\_ENTRY\_ACL\_DELETE
- ARCHIVE\_ENTRY\_ACL\_DELETE\_CHILD
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_DIRECTORY\_INHERIT
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_FAILED\_ACCESS
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_FILE\_INHERIT
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_INHERIT\_ONLY
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_NO\_PROPAGATE\_INHERIT
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_SUCCESSFUL\_ACCESS
- ARCHIVE\_ENTRY\_ACL\_EVERYONE
- ARCHIVE\_ENTRY\_ACL\_EXECUTE
- ARCHIVE\_ENTRY\_ACL\_GROUP
- ARCHIVE\_ENTRY\_ACL\_GROUP\_OBJ
- ARCHIVE\_ENTRY\_ACL\_INHERITANCE\_NFS4
- ARCHIVE\_ENTRY\_ACL\_LIST\_DIRECTORY
- ARCHIVE\_ENTRY\_ACL\_MASK
- ARCHIVE\_ENTRY\_ACL\_OTHER
- ARCHIVE\_ENTRY\_ACL\_PERMS\_NFS4
- ARCHIVE\_ENTRY\_ACL\_PERMS\_POSIX1E
- ARCHIVE\_ENTRY\_ACL\_READ
- ARCHIVE\_ENTRY\_ACL\_READ\_ACL
- ARCHIVE\_ENTRY\_ACL\_READ\_ATTRIBUTES
- ARCHIVE\_ENTRY\_ACL\_READ\_DATA
- ARCHIVE\_ENTRY\_ACL\_READ\_NAMED\_ATTRS
- ARCHIVE\_ENTRY\_ACL\_STYLE\_EXTRA\_ID
- ARCHIVE\_ENTRY\_ACL\_STYLE\_MARK\_DEFAULT
- ARCHIVE\_ENTRY\_ACL\_SYNCHRONIZE
- ARCHIVE\_ENTRY\_ACL\_TYPE\_ACCESS
- ARCHIVE\_ENTRY\_ACL\_TYPE\_ALARM
- ARCHIVE\_ENTRY\_ACL\_TYPE\_ALLOW
- ARCHIVE\_ENTRY\_ACL\_TYPE\_AUDIT
- ARCHIVE\_ENTRY\_ACL\_TYPE\_DEFAULT
- ARCHIVE\_ENTRY\_ACL\_TYPE\_DENY
- ARCHIVE\_ENTRY\_ACL\_TYPE\_NFS4
- ARCHIVE\_ENTRY\_ACL\_TYPE\_POSIX1E
- ARCHIVE\_ENTRY\_ACL\_USER
- ARCHIVE\_ENTRY\_ACL\_USER\_OBJ
- ARCHIVE\_ENTRY\_ACL\_WRITE
- ARCHIVE\_ENTRY\_ACL\_WRITE\_ACL
- ARCHIVE\_ENTRY\_ACL\_WRITE\_ATTRIBUTES
- ARCHIVE\_ENTRY\_ACL\_WRITE\_DATA
- ARCHIVE\_ENTRY\_ACL\_WRITE\_NAMED\_ATTRS
- ARCHIVE\_ENTRY\_ACL\_WRITE\_OWNER
- ARCHIVE\_EOF
- ARCHIVE\_EXTRACT\_ACL
- ARCHIVE\_EXTRACT\_FFLAGS
- ARCHIVE\_EXTRACT\_HFS\_COMPRESSION\_FORCED
- ARCHIVE\_EXTRACT\_MAC\_METADATA
- ARCHIVE\_EXTRACT\_NO\_AUTODIR
- ARCHIVE\_EXTRACT\_NO\_HFS\_COMPRESSION
- ARCHIVE\_EXTRACT\_NO\_OVERWRITE
- ARCHIVE\_EXTRACT\_NO\_OVERWRITE\_NEWER
- ARCHIVE\_EXTRACT\_OWNER
- ARCHIVE\_EXTRACT\_PERM
- ARCHIVE\_EXTRACT\_SECURE\_NODOTDOT
- ARCHIVE\_EXTRACT\_SECURE\_SYMLINKS
- ARCHIVE\_EXTRACT\_SPARSE
- ARCHIVE\_EXTRACT\_TIME
- ARCHIVE\_EXTRACT\_UNLINK
- ARCHIVE\_EXTRACT\_XATTR
- ARCHIVE\_FAILED
- ARCHIVE\_FATAL
- ARCHIVE\_FILTER\_BZIP2
- ARCHIVE\_FILTER\_COMPRESS
- ARCHIVE\_FILTER\_GRZIP
- ARCHIVE\_FILTER\_GZIP
- ARCHIVE\_FILTER\_LRZIP
- ARCHIVE\_FILTER\_LZIP
- ARCHIVE\_FILTER\_LZMA
- ARCHIVE\_FILTER\_LZOP
- ARCHIVE\_FILTER\_NONE
- ARCHIVE\_FILTER\_PROGRAM
- ARCHIVE\_FILTER\_RPM
- ARCHIVE\_FILTER\_UU
- ARCHIVE\_FILTER\_XZ
- ARCHIVE\_FORMAT\_7ZIP
- ARCHIVE\_FORMAT\_AR
- ARCHIVE\_FORMAT\_AR\_BSD
- ARCHIVE\_FORMAT\_AR\_GNU
- ARCHIVE\_FORMAT\_BASE\_MASK
- ARCHIVE\_FORMAT\_CAB
- ARCHIVE\_FORMAT\_CPIO
- ARCHIVE\_FORMAT\_CPIO\_AFIO\_LARGE
- ARCHIVE\_FORMAT\_CPIO\_BIN\_BE
- ARCHIVE\_FORMAT\_CPIO\_BIN\_LE
- ARCHIVE\_FORMAT\_CPIO\_POSIX
- ARCHIVE\_FORMAT\_CPIO\_SVR4\_CRC
- ARCHIVE\_FORMAT\_CPIO\_SVR4\_NOCRC
- ARCHIVE\_FORMAT\_EMPTY
- ARCHIVE\_FORMAT\_ISO9660
- ARCHIVE\_FORMAT\_ISO9660\_ROCKRIDGE
- ARCHIVE\_FORMAT\_LHA
- ARCHIVE\_FORMAT\_MTREE
- ARCHIVE\_FORMAT\_RAR
- ARCHIVE\_FORMAT\_RAW
- ARCHIVE\_FORMAT\_SHAR
- ARCHIVE\_FORMAT\_SHAR\_BASE
- ARCHIVE\_FORMAT\_SHAR\_DUMP
- ARCHIVE\_FORMAT\_TAR
- ARCHIVE\_FORMAT\_TAR\_GNUTAR
- ARCHIVE\_FORMAT\_TAR\_PAX\_INTERCHANGE
- ARCHIVE\_FORMAT\_TAR\_PAX\_RESTRICTED
- ARCHIVE\_FORMAT\_TAR\_USTAR
- ARCHIVE\_FORMAT\_XAR
- ARCHIVE\_FORMAT\_ZIP
- ARCHIVE\_MATCH\_CTIME
- ARCHIVE\_MATCH\_EQUAL
- ARCHIVE\_MATCH\_MTIME
- ARCHIVE\_MATCH\_NEWER
- ARCHIVE\_MATCH\_OLDER
- ARCHIVE\_OK
- ARCHIVE\_READDISK\_HONOR\_NODUMP
- ARCHIVE\_READDISK\_MAC\_COPYFILE
- ARCHIVE\_READDISK\_NO\_TRAVERSE\_MOUNTS
- ARCHIVE\_READDISK\_RESTORE\_ATIME
- ARCHIVE\_RETRY
- ARCHIVE\_VERSION\_NUMBER
- ARCHIVE\_WARN

# EXAMPLES

These examples are translated from equivalent C versions provided on the
libarchive website, and are annotated here with Perl specific details.
These examples are also included with the distribution.

## List contents of archive stored in file

    use strict;
    use warnings;
    use Archive::Libarchive::FFI qw( :all );
    
    # this is a translation to perl for this:
    #  https://github.com/libarchive/libarchive/wiki/Examples#wiki-List_contents_of_Archive_stored_in_File
    
    my $a = archive_read_new();
    archive_read_support_filter_all($a);
    archive_read_support_format_all($a);
    
    my $r = archive_read_open_filename($a, "archive.tar", 10240);
    if($r != ARCHIVE_OK)
    {
      print "r = $r\n";
      die "error opening archive.tar: ", archive_error_string($a);
    }
    
    while (archive_read_next_header($a, my $entry) == ARCHIVE_OK)
    {
      print archive_entry_pathname($entry), "\n";
      archive_read_data_skip($a); 
    }
    
    $r = archive_read_free($a);
    if($r != ARCHIVE_OK)
    {
      die "error freeing archive";
    }

## List contents of archive stored in memory

    use strict;
    use warnings;
    use Archive::Libarchive::FFI qw( :all );
    
    # this is a translation to perl for this:
    #  https://github.com/libarchive/libarchive/wiki/Examples#wiki-List_contents_of_Archive_stored_in_Memory
    
    my $buff = do {
      open my $fh, '<', "archive.tar.gz";
      local $/;
      <$fh>
    };
    
    my $a = archive_read_new();
    archive_read_support_filter_gzip($a);
    archive_read_support_format_tar($a);
    my $r = archive_read_open_memory($a, $buff);
    if($r != ARCHIVE_OK)
    {
      print "r = $r\n";
      die "error opening archive.tar: ", archive_error_string($a);
    }
    
    while (archive_read_next_header($a, my $entry) == ARCHIVE_OK) {
      print archive_entry_pathname($entry), "\n";
      archive_read_data_skip($a); 
    }
    
    $r = archive_read_free($a);
    if($r != ARCHIVE_OK)
    {
      die "error freeing archive";
    }

## List contents of archive with custom read functions

TODO

## A universal decompressor

    use strict;
    use warnings;
    use Archive::Libarchive::FFI qw( :all );
    
    # this is a translation to perl for this:
    #  https://github.com/libarchive/libarchive/wiki/Examples#a-universal-decompressor
    
    my $r;
    
    my $a = archive_read_new();
    archive_read_support_filter_all($a);
    archive_read_support_format_raw($a);
    $r = archive_read_open_filename($a, "hello.txt.gz.uu", 16384);
    if($r != ARCHIVE_OK)
    {
      die archive_error_string($a);
    }
    
    $r = archive_read_next_header($a, my $ae);
    if($r != ARCHIVE_OK)
    {
      die archive_error_string($a);     
    }
    
    while(1)
    {
      my $size = archive_read_data($a, my $buff, 1024);
      if($size < 0)
      {
        die archive_error_string($a);
      }
      if($size == 0)
      {
        last;
      }
      print $buff;
    }
    
    archive_read_free($a);

## A basic write example

    use strict;
    use warnings;
    use autodie;
    use File::stat;
    use Archive::Libarchive::FFI qw( :all );
    
    # this is a translation to perl for this:
    #  https://github.com/libarchive/libarchive/wiki/Examples#wiki-A_Basic_Write_Example
    
    sub write_archive
    {
      my($outname, @filenames) = @_;
      
    my $a = archive_write_new();
    
    archive_write_add_filter_gzip($a);
    archive_write_set_format_pax_restricted($a);
    archive_write_open_filename($a, $outname);
    
    foreach my $filename (@filenames)
    {
      my $st = stat $filename;
      my $entry = archive_entry_new();
      archive_entry_set_pathname($entry, $filename);
      archive_entry_set_size($entry, $st->size);
      archive_entry_set_filetype($entry, AE_IFREG);
      archive_entry_set_perm($entry, 0644);
      archive_write_header($a, $entry);
      open my $fh, '<', $filename;
      my $len = read $fh, my $buff, 8192;
      while($len > 0)
      {
        archive_write_data($a, $buff);
        $len = read $fh, $buff, 8192;
      }
      close $fh;
      
        archive_entry_free($entry);
      }
      archive_write_close($a);
      archive_write_free($a);
    }
    
    unless(@ARGV > 0)
    {
      print "usage: perl basic_write.pl archive.tar.gz file1 [ file2 [ ... ] ]\n";
      exit 2;
    }
    
    unless(@ARGV > 1)
    {
      print "Cowardly refusing to create an empty archive\n";
      exit 2;
    }
    
    write_archive(@ARGV);

## Constructing objects on disk

TODO

## A complete extractor

TODO

# CAVEATS

Archive and entry objects are really pointers to opaque C structures
and need to be freed using one of `archive_read_free`, `archive_write_free`
or `archive_entry_free`, in order to free the resources associated
with those objects.

The documentation that comes with libarchive is not that great, but
is serviceable.  The documentation for this library is copied largely
from libarchive, with adjustments for Perl.

# SEE ALSO

The intent of this module is to provide a low level fairly thin direct
interface to libarchive, on which a more Perlish OO layer could easily
be written.

- [Archive::Libarchive::XS](https://metacpan.org/pod/Archive::Libarchive::XS)
- [Archive::Libarchive::FFI](https://metacpan.org/pod/Archive::Libarchive::FFI)

    Both of these provide the same API to libarchive via [Alien::Libarchive](https://metacpan.org/pod/Alien::Libarchive),
    but the bindings are implemented in XS for one and via [FFI::Sweet](https://metacpan.org/pod/FFI::Sweet) for
    the other.

- [Archive::Libarchive::Any](https://metacpan.org/pod/Archive::Libarchive::Any)

    Offers whichever is available, either the XS or FFI version.

- [Archive::Peek::Libarchive](https://metacpan.org/pod/Archive::Peek::Libarchive)
- [Archive::Extract::Libarchive](https://metacpan.org/pod/Archive::Extract::Libarchive)

    Both of these provide a higher level perlish interface to libarchive.

- [Archive::Tar](https://metacpan.org/pod/Archive::Tar)
- [Archive::Tar::Wrapper](https://metacpan.org/pod/Archive::Tar::Wrapper)

    Just some of the many modules on CPAN that will read/write tar archives.

- [Archive::Zip](https://metacpan.org/pod/Archive::Zip)

    Just one of the many modules on CPAN that will read/write zip archives.

- [Archive::Any](https://metacpan.org/pod/Archive::Any)

    A module attempts to read/write multiple formats using different methods
    depending on what perl modules are installed, and preferring pure perl
    modules.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
