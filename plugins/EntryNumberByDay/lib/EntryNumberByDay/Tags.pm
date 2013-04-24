package EntryNumberByDay::Tags;
use strict;
use MT;
use MT::Plugin;

use MT::Util qw( start_end_day );

sub _handler_entry_number_by_day {
	my ($ctx, $args, $cond) = @_;
	my $tokens = $ctx->stash('tokens');
	my $builder = $ctx->stash('builder');
	my $blog = $ctx->stash('blog');
	my $entry = $ctx->stash('entry') or return '';
	my $prefix = $args->{prefix} || '';
	my $pad = $args->{zeropad} || 0;
	my $always = $args->{always} || 0;
	my $blog_id = $blog->id;
	my $ts = $entry->authored_on;
	my ($start,$end) = start_end_day($ts);
	$end++;
	$start--;
	my @entries = MT->model('entry')->load( {
										blog_id => $blog_id,
										status  => MT::Entry::RELEASE(),
										authored_on => [$start, $end],
									},
									{
										range  => { authored_on => 1 },
										sort => 'authored_on',
										direction => 'ascend',
									});
	my $count = scalar @entries;
	if ($count == 1) {
		if ($always) {
			my $number = ($pad ? sprintf("%0${pad}d", "1") : 1);
			return $prefix . $number;
		} else {
			return '';
		}
	}
	my $counter = 0;
	for my $e (@entries) {
		$counter++;
		if ( $e->id == $entry->id ) {
			my $number = ($pad ? sprintf("%0${pad}d", $counter) : $counter);
			if ($counter == 1) {
				if ($always) {
					return $prefix . $number;
				}
				return '';
			}
			return $prefix . $number;
		}
	}
	return '';
}

sub _handler_entry_number_on_category {
	my ($ctx, $args, $cond) = @_;
	my $tokens = $ctx->stash('tokens');
	my $builder = $ctx->stash('builder');
	my $blog = $ctx->stash('blog');
	my $entry = $ctx->stash('entry') or return '';
	my $category = $entry->category || '';
	my $prefix = $args->{prefix} || '';
	my $pad = $args->{zeropad} || 0;
	my $always = $args->{always} || 0;
	my $blog_id = $blog->id;
	my $ts = $entry->authored_on;
	my ($start,$end) = start_end_day($ts);
	$end++;
	$start--;
	my @entries;
	if ($category) {
		@entries = MT->model('entry')->load( {
											blog_id => $blog_id,
											status  => MT::Entry::RELEASE(),
											authored_on => [$start, $end],
										},
										{
											range  => { authored_on => 1 },
											sort => 'authored_on',
											direction => 'ascend',
											join => MT->model('placement')->join_on(
												'entry_id',
												{ category_id => $category->id },
												{ unique => 1 }
											),
										});
	} else {
		@entries = MT->model('entry')->load( {
										blog_id => $blog_id,
										status  => MT::Entry::RELEASE(),
										authored_on => [$start, $end],
									},
									{
										range  => { authored_on => 1 },
										sort => 'authored_on',
										direction => 'ascend',
										join => MT->model('placement')->join_on(
											undef,
											{
												id => \'is null',
											},
											{
												type => 'left',
												condition => {
													entry_id => \'= entry_id',
												},
											},
										),
									});
	}
	my $count = scalar @entries;
	if ($count == 1) {
		if ($always) {
			my $number = ($pad ? sprintf("%0${pad}d", "1") : 1);
			return $prefix . $number;
		} else {
			return '';
		}
	}
	my $counter = 0;
	for my $e (@entries) {
		$counter++;
		if ( $e->id == $entry->id ) {
			my $number = ($pad ? sprintf("%0${pad}d", $counter) : $counter);
			if ($counter == 1) {
				if ($always) {
					return $prefix . $number;
				}
				return '';
			}
			return $prefix . $number;
		}
	}
	return '';
}

1;