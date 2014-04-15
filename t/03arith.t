use warnings;
use strict;
use Math::Float128 qw(:all);

print "1..9\n";

# Try to determine when the decimal point is a comma,
# and set $dp accordingly.
my $dp = '.';
$dp = ',' unless Math::Float128->new('0,5') == Math::Float128->new(0);

#print "\$dp: $dp\n";

my $n = Math::Float128->new("3${dp}5");
my $unity = UnityF128(1);
my $two = Math::Float128::UVtoF128(2);

if(-$unity == UnityF128(-1)) {print "ok 1\n"}
else {print "not ok 1\n"}

$n = $n + $unity;
if($n == Math::Float128->new("4${dp}5")){print "ok 2\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 2\n";
}

$n = $n - $unity;
if($n == Math::Float128->new("3${dp}5")){print "ok 3\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 3\n";
}

$n = $n * $two;

if($n == Math::Float128->new('7')){print "ok 4\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 4\n";
}

$n = $n / $two;
if($n == Math::Float128->new("3${dp}5")){print "ok 5\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 5\n";
}

$n += $unity;
if($n == Math::Float128->new("4${dp}5")){print "ok 6\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 6\n";
}

$n -= $unity;
if($n == Math::Float128->new("3${dp}5")){print "ok 7\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 7\n";
}

$n *= $two;
if($n == Math::Float128->new('7')){print "ok 8\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 8\n";
}

$n /= $two;
if($n == Math::Float128->new("3${dp}5")){print "ok 9\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 9\n";
}