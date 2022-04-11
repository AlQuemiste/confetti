use warnings;
use strict;
use feature 'say';
use Data::Dumper;
#----------------------------------------

my $dir = "/Users/alq/Projects/bornagain/build/lib";
my $ext = ".so";
my @libs = glob("$dir/*$ext");

my @all_opt_deps;

sub unique {
    # make a hashmap from the given list, so that the keys are automatically unique
    my %m = map { $_ => 1 } @_;
    return keys %m;
}

my $lib_id_re = qr'LC_ID_DYLIB\s*\n.+\n\s*name\s+([./\w-]+)';
sub dylib_id {
    my $lib = $_[0];
    return (`otool -l $lib` =~ $lib_id_re)[0];
}

my $path_basename_re = qr'\A\s*([\w/].+)/([\w.-]+)';
my (@ex_deps, @py_deps, @ba_deps);

my $level = 0;
while (@libs) {
    my @deps_lv = ();
    ++$level;
    print "* Level $level\n"; 
    foreach my $lib (@libs) {
	my @deps = split "\n", qx(otool -L $lib | tail -n+3);
	push @py_deps, (grep m/python/i, @deps);
	push @ba_deps, (grep m/bornagain/i, @deps);
	
	my @opt_deps = grep m/opt|cellar/i, @deps;
	my @deps_lib = ();
	print "L$level> $lib\n"; 
	foreach my $dp (@opt_deps) {
	    next if($dp =~ m/Qt/ or $dp =~ m/python|bornagain/i);
	    my ($dir, $fnm) = ($dp =~ $path_basename_re);
	    next if(! $dir);
	    push @deps_lib, "$dir/$fnm";
	}
	push @deps_lv, @deps_lib;
    }

    @deps_lv = unique @deps_lv;
    @libs = @deps_lv;
    push @ex_deps, @libs;

    if (@deps_lv) {
	print "** Dependencies at level $level:\n";
	for my $dp (@deps_lv) {
	    print "  > '$dp'\n";
	}
    }
}

@ex_deps = unique @ex_deps;

print "* all dependences up to level $level:\n";

for my $lib (@ex_deps) {
    my $lib_id = dylib_id $lib;
    print "  > '$lib'\n";
    print "    id = '$lib_id'";
    $lib eq $lib_id? print " =" : print " !=";
    print "\n";
}

@py_deps = unique @py_deps;
print "Python dependence:\n";
for my $lib (@py_deps) {
    my ($libpath, $libref) = ($lib =~ qr'\s*(/.+)/([\w.-]+)');
    next if (! $libref);
    my $pyver = ($libpath =~ qr'.+Versions/([\d.]+)')[0];
    print "> '$lib'\n";
    print "py$pyver,  '$libpath/$libref'\n";
}

@ba_deps = unique @ba_deps;
print "BornAgain dependence:\n";
foreach my $lib (@ba_deps) {
    my ($libpath, $libnm) = ($lib =~ qr'\s*(.+)/([\w.-]+)');
    my $libref = ($libnm =~ s/([\w]+)\.[\d.]+\.([[:alpha:]]+)/$1.$2/r);
    print "'$libpath/$libnm' => '$libref'\n"; 
}

=pod
This is a long comment.
This is another line of comment.
=cut

