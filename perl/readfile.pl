use strict;
use warnings;

# my $file = 'testls.txt';
my $file = "$ENV{HOME}/Documents/mega_ls.txt";
my $dir_re = qr'\A(/.+):';
my $filename_re = '([\w\[\]();,\'._<>@"#$%^&!\h-]+)';
my $filedesc_re = qr'----[[:blank:]]+([[:alnum:]:.]+ +){5}(.+)$';

my $linec = 0;
my $curdir = "/";
my $SEP = ":\0\0:";

my (%namelist, %duplicates);

print "Reading file '$file'...\n";
open(LISTFILE, $file) or die("Could not open file '$file'.");

foreach my $line (<LISTFILE>)  {
    $linec++;
    # print "L$linec)", $line;
    # the current directory
    my ($dirnm) = ($line =~ $dir_re);
    if($dirnm) {
      print ">> '$dirnm'\n";
      $curdir = $dirnm;
    } else {
      my $fnm = ($line =~ $filedesc_re)[1];
      if($fnm) {
        print "   * '$fnm'";
        my $basename = ($fnm =~ m/([\w;,\'._ <>@"#$%^&?!\h-]+).*\.[[:alpha:]]{2,4}\z/)[0];
        if ($basename) {
          my $basehash = (lc ($basename =~ s/[^[:alpha:]]//gr));
          my $founddirs = $namelist{$basehash};
          my $pth = "$curdir/$fnm";
          if($founddirs) {
            $namelist{$basehash} = $founddirs . $SEP . "$pth";
            $duplicates{$basehash} = $fnm;
          } else {
            $namelist{$basehash} = "$pth";
          }
          print " => '$basename' => '$basehash'\n";
        } else {
          print " => <NO BASENAME>\n";
        }
      }
    }
}

print "\n* Duplicates found:\n";
foreach my $fhash (keys %duplicates) {
  my $fnm = $duplicates{$fhash};
  print "  > '$fnm' found in:\n";
  foreach my $dir (split $SEP, $namelist{$fhash}) {
    print "     + $dir\n";
  }
}

close(LISTFILE);
print "\n...Done.\n";
