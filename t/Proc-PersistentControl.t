# -*-perl-*-
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Proc-PersistentControl.t'

#########################

use strict;
use warnings;

use Test;
BEGIN { plan tests =>  9 };
use Proc::PersistentControl;

ok(1); # If we made it this far, we're ok.

#########################

my $module_path = $INC{'Proc/PersistentControl.pm'};
$module_path =~ s|(.*)[/\\].*|$1|;
my $psleep = $module_path . '/PersistentControl/examples/psleep';

ok(-r $psleep, 1); # check we have psleep

my $tp = Proc::PersistentControl->new();
my $p1 = $tp->StartProc({ TAG => 'sl3600' }, "$psleep 3600");
my $p2 = $tp->StartProc({ timeout => 5, TAG => 'sl3601' }, "$psleep 3601");

my $alive = $p1->IsAlive();
ok($alive, 1); # Check started Job is alive

sleep(1); # Give it time to print its STDERR/STDOUT

$p1->Kill();

$alive = $p1->IsAlive();
ok($alive, 0); # Started Job should be killed

my $Info = $p1->Reap();
my $e    = $Info->{_dir} . '/STDERR';

ok(-r $e, 1); # check STDERR is readable

open(F, $e);
my $l = <F>;
close(F);

ok($l, qr/Sleeping for 3600/); # stderr check of job

ok($p2->IsAlive(), 1); # p2 should still be running

sleep(5);

ok($p2->IsRipe(), 1); # should have been terminated due to timeout

$Info = $p2->Reap();
$e    = $Info->{_dir} . '/STDERR';

ok(-r $e, 1); # check STDERR is readable

