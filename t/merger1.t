#!/usr/bin/perl -w
#!/usr/bin/perl -d:ptkdb
#


use strict;


our $disabled_tests;

BEGIN
{
    $disabled_tests
	= {
	   1 => '',
	  };
}


use Test::More tests => (scalar ( grep { !$_ } values %$disabled_tests ) );

use Data::Comparator qw(data_comparator);
use Data::Merger qw(merger);


if (!$disabled_tests->{1})
{
    my $target
	= {
           a => 2,
	   e => {
		 e1 => {
		       },
		},
	  };

    my $source
	= {
           a => 1,
	   e => {
		 e2 => {
		       },
		 e3 => {
		       },
		},
	  };

    my $expected_data
	= {
           a => 1,
	   e => {
		 e1 => {
		       },
		 e2 => {
		       },
		 e3 => {
		       },
		},
	  };

    my $merged_data = merger($target, $source);

    use Data::Comparator qw(data_comparator);

    my $differences = data_comparator($merged_data, $expected_data);

    use Data::Dumper;

    print Dumper($differences);

    ok($differences->is_empty(), 'simple merge');
}


