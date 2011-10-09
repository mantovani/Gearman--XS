use inc::Module::Install;
use Env qw(GEARMAN_LIB GEARMAN_INCLUDE);
use vars qw($INCLUDES);

my $LIBS = '';
$INCLUDES = '-I.';

if (defined $GEARMAN_LIB) {
  print STDERR "Using GEARMAN_LIB = $GEARMAN_LIB\n";
  $LIBS .= " -L$GEARMAN_LIB ";
}

if (defined $GEARMAN_INCLUDE) {
  print STDERR "Using GEARMAN_INCLUDE = $GEARMAN_INCLUDE\n";
  $INCLUDES .= " -I$GEARMAN_INCLUDE";
}

$LIBS .= ' -lgearman';

name 'Gearman-XS';
all_from 'lib/Gearman/XS.pm';
no_index directory => 'examples';

can_cc or die "This module requires a C compiler";

makemaker_args(
    INC     => $INCLUDES,
    LIBS    => $LIBS,
    # CCFLAGS => '-Werror -Wall -Wundef -Wshadow -Wmissing-prototypes -fdiagnostics-show-option -Wformat=2 -Wstrict-aliasing -Wextra -Wmissing-declarations -Wcast-align -Wswitch-default -Wswitch-enum',
    clean   => {
        FILES => q{
            MANIFEST
        },
    },
);

cc_files map { "$_\.c" } qw/XS Const Client Worker Job Task/;
tests 't/*.t';

test_requires 'Test::More';
test_requires 'Storable';
WriteAll;