use warnings;
use strict;
use Math::Float128 qw(:all);

print "1..3\n";

my $r = 2.0;
my $r2 = 1.5;
my $ldr = Math::Float128->new(2.0);
my $ldr2 = Math::Float128->new(1.5);

my $sin_r = sin($r);
my $cos_r = cos($r);
my $atan2_r = atan2($r, $r2);

my $sin_ldr = sin($ldr);
my $cos_ldr = cos($ldr);
my $atan2_ldr = atan2($ldr, $ldr2);

if(approx($sin_ldr, $sin_r) && test_cmp($sin_ldr, $sin_r)) {print "ok 1\n"}
else {
  warn "\n\$sin_ldr: $sin_ldr\n\$sin_r: $sin_r\n";
  print "not ok 1\n";
}

if(approx($cos_ldr, $cos_r) && test_cmp($cos_ldr, $cos_r)) {print "ok 2\n"}
else {
  warn "\n\$cos_ldr: $cos_ldr\n\$cos_r: $cos_r\n";
  print "not ok 2\n";
}

if(approx($atan2_ldr, $atan2_r) && test_cmp($atan2_ldr, $atan2_r)) {print "ok 3\n"}
else {
  warn "\n\$atan2_ldr: $atan2_ldr\n\$atan2_r: $atan2_r\n";
  print "not ok 3\n";
}



sub approx {
    my $eps = abs($_[0] - Math::Float128->new($_[1]));
    return 0 if  $eps > Math::Float128->new(0.000000001);
    return 1;
}

sub test_cmp {
  return cmp2NV($_[0], $_[1]);
}