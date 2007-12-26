#!/usr/bin/perl -w
#!/usr/bin/perl -d:ptkdb -w
#
# This module is based on code that was implemented
# when working for Newtec Cy, located in Belgium,
# http://www.newtec.be/.
#

package Data::Merger;


use strict;


#
# subs to merge two datastructures.
#

sub merger_any
{
    my $contents = shift;

    my $data = shift;

    my $options = shift;

    # simply check what kind of data structure we are dealing
    # with and forward to the right sub.

    my $type = ref $contents;

    if ($type eq 'HASH')
    {
	merger_hash($contents, $data, $options);
    }
    elsif ($type eq 'ARRAY')
    {
	merger_array($contents, $data, $options);
    }
    else
    {
	die "$0: *** Error: Data::Merger error: merger_any() encounters an unknown data type $type";
    }
}


sub merger_hash
{
    my $contents = shift;

    my $data = shift;

    my $options = shift;

    # loop over all values in the contents hash.

    foreach my $section (keys %$data)
    {
	if (exists $contents->{$section})
	{
	    my $value = $data->{$section};

	    my $contents_type = ref $contents->{$section};
	    my $value_type = ref $value;

	    if ($contents_type && $value_type)
	    {
		if ($contents_type eq $value_type)
		{
		    # two references of the same type, go one
		    # level deeper.

		    merger_any($contents->{$section}, $value, $options);
		}
		else
		{
		    die "$0: *** Error: Data::Merger error: contents_type is '$contents_type' and does not match with value_type $value_type";
		}
	    }
	    elsif (!$contents_type && !$value_type)
	    {
		# copy scalar value

		$contents->{$section} = $value;
	    }
	    else
	    {
		die "$0: *** Error: Data::Merger error: contents_type is '$contents_type' and does not match with value_type $value_type";
	    }
	}
	else
	{
	    #t could be a new key being added.
	}
    }
}


sub merger_array
{
    my $contents = shift;

    my $data = shift;

    my $options = shift;

    # loop over all values in the contents array.

    my $count = 0;

    foreach my $section (@$data)
    {
	if (exists $contents->[$count]
	    || $options->{arrays}->{overwrite} eq 1)
	{
	    my $value = $data->[$count];

	    my $contents_type = ref $contents->[$count];
	    my $value_type = ref $value;

	    if ($contents_type && $value_type)
	    {
		if ($contents_type eq $value_type)
		{
		    # two references of the same type, go one
		    # level deeper.

		    merger_any($contents->[$count], $value, $options);
		}
		else
		{
		    die "$0: *** Error: Data::Merger error: contents_type is '$contents_type' and does not match with value_type $value_type";
		}
	    }
	    elsif (!$contents_type && $value_type
		   && $options->{arrays}->{overwrite} eq 1)
	    {
		# overwrite array content

		$contents->[$count] = $value;
	    }
	    elsif (!$contents_type && !$value_type)
	    {
		# copy scalar value

		$contents->[$count] = $value;
	    }
	    else
	    {
		die "$0: *** Error: Data::Merger error: contents_type is '$contents_type' and does not match with value_type $value_type";
	    }
	}
	else
	{
	    #t could be a new key being added.
	}

	$count++;
    }
}


sub merger
{
    my $target = shift;

    my $source = shift;

    my $options = shift;

    #t I don't think the todos below are still valid, the idea is
    #t sound though:

    #t Should actually use a simple iterator over the detransformed data
    #t that keeps track of examined paths.  Then use the path to store
    #t encountered value in the original data.

    #t Note that the iterator is partly implemented in Sesa::Transform and
    #t Sesa::TreeDocument.  A further abstraction could be useful.

    # first inductive step : merge all data.

    merger_any($target, $source, $options);

    return $target;
}


1;


