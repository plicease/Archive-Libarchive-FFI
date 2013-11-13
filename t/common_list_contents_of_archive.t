use strict;
use warnings;
use Archive::Libarchive::FFI qw( :all );
use Test::More tests => 10;
use FindBin ();
use File::Spec;

foreach my $mode (qw( memory filename ))
{
  foreach my $format (qw( tar tar.gz tar.bz2 xar zip ))
  {
    subtest "$format $mode" => sub {
      plan tests => 21;
    
      my $filename = File::Spec->catfile($FindBin::Bin, "foo.$format");
      my $r;
      my $entry;
    
      note "filename = $filename";

      my $a = archive_read_new();

      isa_ok $a, "Archive::Libarchive::FFI::archive";
 
      $r = archive_read_support_filter_all($a);
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_support_filter_all)";

      $r = archive_read_support_format_all($a);
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_support_format_all)";

      if($mode eq 'memory')
      {
        open my $fh, '<', $filename;
        my $buffer = do { local $/; <$fh> };
        close $fh;
        $r = archive_read_open_memory($a, $buffer);
      }
      else
      {
        $r = archive_read_open_filename($a, $filename, 10240);
      }
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_open_$mode)";

      $r = archive_read_next_header($a, $entry);
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_next_header 1)";
      isa_ok $entry, "Archive::Libarchive::FFI::archive_entry";

      is archive_file_count($a), 1, "archive_file_count = 1";

      is archive_entry_pathname($entry), "foo/foo.txt", 'archive_entry_pathname($entry) = foo/foo.txt';

      note 'archive_filter_count     = ' . archive_filter_count($a);
      for(0..(archive_filter_count($a)-1)) {
        note "archive_filter_code($_)  = " . archive_filter_code($a,$_);
        note "archive_filter_name($_)  = " . archive_filter_name($a,$_);
      }
      note "archive_format           = " . archive_format($a);
      note "archive_format_name      = " . archive_format_name($a);

      $r = archive_read_data_skip($a);
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_data_skip 1)";

      $r = archive_read_next_header($a, $entry);
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_next_header 2)";
      isa_ok $entry, "Archive::Libarchive::FFI::archive_entry";

      is archive_file_count($a), 2, "archive_file_count = 2";

      is archive_entry_pathname($entry), "foo/bar.txt", 'archive_entry_pathname($entry) = foo/bar.txt';

      $r = archive_read_data_skip($a);
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_data_skip 2)";

      $r = archive_read_next_header($a, $entry);
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_next_header 3)";
      isa_ok $entry, "Archive::Libarchive::FFI::archive_entry";

      is archive_file_count($a), 3, "archive_file_count = 3";

      is archive_entry_pathname($entry), "foo/baz.txt", 'archive_entry_pathname($entry) = foo/baz.txt';

      $r = archive_read_data_skip($a);
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_data_skip 3)";

      $r = archive_read_next_header($a, $entry);
      is $r, ARCHIVE_EOF, "r = ARCHIVE_EOF (archive_read_next_header 4)";
 
      $r = archive_read_free($a);
      is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_free)";
    }
  }
}
