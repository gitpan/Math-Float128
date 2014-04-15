use warnings;
use strict;
use Math::Float128 qw(:all);
use Config;

print "1..7\n";

my $n = 1.3;
my $nld = Math::Float128->new(1.3);

my $exp = exp($n);
my $exp_ld = exp($nld);
my $log_ld = log($exp_ld);
my $two = Math::Float128->new(2.0);
my $log = log($two);

# Try to determine when the decimal point is a comma,
# and set $dp accordingly.
my $dp = '.';
$dp = ',' unless Math::Float128->new('0,5') == Math::Float128->new(0);

if(approx($exp_ld, $exp)) {print "ok 1\n"}
else {
  warn "\n\$exp_ld: $exp_ld\n\$exp: $exp\n";
  print "not ok 1\n";
}

if(approx($log_ld, $n)) {print "ok 2\n"}
else {
  warn "\n\$log_ld: $log_ld\n\$n: $n\n";
  print "not ok 2\n";
}

if(is_InfF128(log(ZeroF128(1)))) {print "ok 3\n"}
else {
  warn "\nlog(0): ", log(ZeroF128(1)), "\n";
  print "not ok 3\n";
}

if(is_NaNF128(log(UnityF128(-1)))) {print "ok 4\n"}
else {
  warn "\nlog(-1): ", log(UnityF128(-1)), "\n";
  print "not ok 4\n";
}

if(cmp2NV($log, log(2.0))) {print "ok 5\n"}
else {
  warn "\n\$log: ", log($two), "\nlog(2.0): ", log(2.0), "\n";
  print "not ok 5\n";
}

if(approx($log, Math::Float128->new("6${dp}9314718055994530943e-001"))) {print "ok 6\n"}
else {
  warn "\n\$log: $log\n";
  print "not ok 6\n";
}

if(cmp2NV($exp_ld, $exp)) {print "ok 7\n"}
else {
  warn "\n\$exp_ld: $exp_ld\n\$exp: $exp\n";
  print "not ok 7\n";
}

sub approx {
    my $eps = abs($_[0] - Math::Float128->new($_[1]));
    return 0 if $eps > Math::Float128->new(0.000000001);
    return 1;
}