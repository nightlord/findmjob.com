#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../../lib"; # FindmJob::Basic etc.
use lib "$Bin/../lib";    # FindmJob::Role::
use lib "$Bin/lib";       # FindmJob::Scrape::
use Getopt::Long;
use Class::Load 'load_class';

my $m;
my %options;
GetOptions(
    "m|module=s" => \$m,
    "u|update"   => \$options{opt_update},
) or die "error parsing opt";

unless ($m) {
    die <<USAGE;
perl $0 [options]
    options:
        -m, --module        running module, eg: JobsPerlOrg
        --update            in updating mode
USAGE
}

my $module = "FindmJob::Scrape::$m";
load_class($module) or die "Failed to load $module\n";

$module->new(%options)->run;

1;