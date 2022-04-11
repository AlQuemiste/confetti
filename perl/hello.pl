#!/usr/bin/perl
use warnings;
use strict;
use feature 'say';

print("Hello, World!\n");

say("Hello, World!");

my $salary = 2;
$salary = 2;
$salary *= 1.05;

print("salary = " . $salary . "\n");

my $color;
$color = 'red';
print("my favorite #1 color is " . $color . "\n");
 # another block
{
     my $color = 'blue';
     print("my favorite #2 color is " . $color . "\n");
}
# for checking
print("my favorite #1 color is " . $color . "\n");

my $name = 'Jack';
my $s2 = qq/"Are you learning Perl String today?"$name asked./;
print($s2 ,"\n");

my $s3 = "Change cases of a string";
print("To upper case:\n");
print(uc($s3), "\n");
print("To lower case:\n");
print(lc($s3), "\n");

print 10 + 20, "\n"; # 20

print "message " x 3 . "\n";

print(10,20,30); # display 102030
print("\n");
print("this", "is", "a","list", "\n");

my $x = 10;
my $s = "a string";
print("complex list", $x , $s ,"\n");
my $g = "complex list". $x . $s ."\n";
print($g);

my @l = qw(red green blue);
print($l[-1], "\n"); # redgreenblue
print(@l, "\n");

my $count = @l;
print("count = ", $count, "\n");

my @fruits = qw(oranges apples mango cucumber);
my @sorted = sort @fruits;

print "@sorted","\n"; # apples cucumber mango oranges

my %langs = ( England => 'English',
              France => 'French',
              Spain => 'Spanish',
              China => 'Chinese',
              Germany => 'German');

# get language of England
my $lang = $langs{'England'}; # English
print($lang,"\n");

for(keys %langs){
	print("Official Language of $_ is $langs{$_}\n");
}

my $a = 1;
print("Welcome to Perl if tutorial\n") if($a == 1);

if($a != 1) {
    print("--Welcome to Perl if tutorial\n");
} else {
    print("---\n");

}

my @a = (1..9);
for my $i (@a){
	print("$i","\n");
}



my $s1 = 'Perl regular expression is powerful';
print "match found\n" if( $s1 =~ /ul/);


my @html = (
	   '<p>',
	   'html fragement',
	   '</p>',
	   '<br>',
	   '<span>This is a span</span>'
	);

foreach(@html){
   print("$_ \n") if($_ =~ m"/");
}

my $re = qr/ul/;
my $string = "Fooo";
$string =~ /foo${re}bar/; # can be interpolated in other patterns
$string =~ $re; # or used standalone
$string =~ /$re/; # or this way

my $v1 = " a string   ";
print("!True!\n") if ("  ");

sub  trim {
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}

my @args = ("ls", "-a", "-h", "-v");
system(@args) == 0 or die "system @args failed: $?";

print("'", __LINE__." ", trim($v1), "'\n");

my $alloutput = `ls -lh`;
print("output: '\n", $alloutput, "\n'\n");

my @outl = split(" ", $alloutput);
for my $e (@outl) {
    print "> '". $e . "'\n";
}

# Function definition
sub Average {
   # get total number of arguments passed
   my $n = scalar(@_);
   my $sum = 0;

   foreach my $item (@_) {
      $sum += $item;
   }
   my $average = $sum / $n;

   print "Average of {@_}: $average\n";
   return $average;
}

# Function call
say "\n", "Function call:";
my $avg = &Average(10, 20, 30);
