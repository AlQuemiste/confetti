# file operations
use warnings;
use strict;
use Cwd qw(cwd getcwd);

#----------------------------------------
my $root = "$ENV{HOME}/Projects";
my @project_dirs = ("$root/libheinz", "$root/libformfactor", "$root/libcerf");
my $install_prefix = "$ENV{HOME}/.local/opt";

# CMake commands
my $build_dir = "build";
my $n_threads = 4;
my $cmake_config = "cmake -B $build_dir -DCMAKE_INSTALL_PREFIX:PATH=$install_prefix";
my $cmake_build = "cmake --build $build_dir --parallel $n_threads --config Release";
my $cmake_install = "cmake --install $build_dir";

# Git commands
my $git_pull = "git pull --prune";
my $main_branch_re = qr'\s*HEAD branch:[[:blank:]]+([[:alnum:]_.-]+)';
sub git_main_branch {
    return (`git remote show origin` =~ $main_branch_re)[0];
}

sub build_project {
    # update the repo and build a project
    my $dir = $_[0];
    chdir $dir;
    my $dir0 = cwd;
    my $main_branch = git_main_branch;
    print "> Update branch '$main_branch'...\n";
    system($git_pull) == 0 || die;
    print "> CMake...\n";
    system($cmake_config) == 0 || die;
    system($cmake_build) == 0 || die;
    system($cmake_install) == 0 || die;
}

foreach my $prj (@project_dirs) {
    print "\n=> Project at '$prj' <=\n";
    build_project "$prj";
}

=pod
This is a long comment.
This is another line of comment.
=cut
