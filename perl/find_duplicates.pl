use strict;
use warnings;

# my $file = 'testls.txt';
my $file = "$ENV{HOME}/Documents/megafiles.txt";
# regexp to extract directory and filename
my $path_re = qr'\A(.+/)(.+)$';
my $basename_re = '([^\[(]+)\s+[\[(].+$|(.+)\.[[:alnum:]]*$';

my $linec = 0; # line counter
my $curdir = "/";
my $SEP = ":\0\0:";

my (%namelist, %duplicates);

print "Reading file '$file'...\n";
open(LISTFILE, $file) or die("Could not open file '$file'.");

foreach my $line (<LISTFILE>)  {
    # $linec++;
    # print "L$linec)", $line;

    # the current directory
    my ($dirnm, $fnm) = ($line =~ $path_re);
    if(! $dirnm) {
        next;
    }

    my ($basenm) = ($fnm =~ $basename_re);
    if (! $basenm) {
        next;
    }

    my $basehash = lc ($basenm =~ s/[[:alpha:]]+\s*-\s*(.+)\s*/$1/r =~ s/[^[:alpha:]]//gr);

    my $founddirs = $namelist{$basehash};
    if($founddirs) {
        $namelist{$basehash} .= $SEP . "$line";
        $duplicates{$basehash} = $basenm;
    } else {
        $namelist{$basehash} = "$line";
    }

    # info:
    # print ">> '$dirnm'\n";
    # print "    file: '$fnm'\n";
    # print "    basename: '$basenm'\n";
    # print "    hash: '$basehash'\n";
    # $founddirs && print "   FOUND!\n";

    # $linec > 20 && last;
}

close(LISTFILE);

print "========================================\n";
print "* Duplicates found:\n";
while(my ($fhash, $fnm) = each %duplicates) {
  #my $fnm = $duplicates{$fhash};
  print "### '$fnm':\n";
  foreach my $dir (split $SEP, $namelist{$fhash}) {
    print "* $dir\n";
  }
}

print "\n...Done.\n";
