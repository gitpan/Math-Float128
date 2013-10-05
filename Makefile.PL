use ExtUtils::MakeMaker;
my %options = %{
{
  'NAME' => 'Math::Float128',
  'LIBS' => [
    '-lquadmath -lm'
  ],
  'INC' => '',
  'VERSION_FROM' => 'Float128.pm'
}
};
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
