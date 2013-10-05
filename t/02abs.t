use warnings;
use strict;
use Math::Float128 qw(:all);

print "1..5\n";

my $nan = NaNF128();
my $zero = ZeroF128(1);
my $nzero = ZeroF128(-1);
my $unity = UnityF128(1);
my $nunity = UnityF128(-1);
my $inf = InfF128(1);
my $ninf = InfF128(-1);

if(abs($nunity) == $unity) {print "ok 1\n"}
else {
  warn "abs(\$nunity): ", abs($nunity), "\n\$unity: $unity\n";
  print "not ok 1\n";
}

if(abs($ninf) == $inf) {print "ok 2\n"}
else {
  warn "abs(\$ninf): ", abs($ninf), "\n\$inf: $inf\n";
  print "not ok 2\n";
}

if(abs($nzero) == $zero) {print "ok 3\n"}
else {
  warn "abs(\$nzero): ", abs($nzero), "\n\$zero: $zero\n";
  print "not ok 3\n";
}

if(is_ZeroF128(abs($nzero)) <= 0) {print "not ok 4\n"}
else {print "ok 4\n"}

if(is_NaNF128(abs($nan))) {print "ok 5\n"}
else {print "not ok 6\n"}