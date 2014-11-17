use ExtUtils::MakeMaker;
use Config;

my $defines = $] < 5.008 ? "-DOLDPERL" : "-DNEWPERL";

$defines .= $Config{byteorder} =~ /^1234/ ? " -DWE_HAVE_LENDIAN" : " -DWE_HAVE_BENDIAN";

$defines .= " -DLONGLONG2IV_IS_OK"
  if $Config{ivsize} >= $Config{longlongsize};

$defines .= " -DLONG2IV_IS_OK"
  if $Config{ivsize} >= $Config{longsize};

my %options = %{
{
  'NAME' => 'Math::Float128',
  'DEFINE' => $defines,
  'LIBS' => [
    '-lquadmath -lm'
  ],
  'INC' => '',
  'LICENSE'  => 'perl',
  'VERSION_FROM' => 'Float128.pm',
  META_MERGE => {
   'meta-spec' => { version => 2 },
    resources => {
      repository => {
        type => 'git',
        url => 'https://github.com/sisyphus/math-float128.git',
        web => 'https://github.com/sisyphus/math-float128',
      },
    },
  },
}
};
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
