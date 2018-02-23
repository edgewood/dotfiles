#!/usr/bin/perl

sub todotxt_usage
{
	my ($cmdname, $description, @extra) = @_;
	print "    $cmdname\n";
	print "      $description\n";
	foreach $line (@extra)
	{
		print "      $line\n";
	}
}

sub todotxt_run_custom_action
{
	my ($argsref, $usagefunc, $actionfunc) = @_;
	my @args = @$argsref;
	if ($args[0] =~ m/usage/i)
	{
		&$usagefunc();
	}
	else
	{	
		&$actionfunc(@args);
	}
}

sub todotxt_get_cfg_option
{
	my ($option) = @_;
	my $optval = undef;
	my $TODO_DIR = $ENV{'HOME'};
	my $HOMEDIR = $ENV{'HOME'};

	open (CFG, $ENV{'HOME'} . "/.todo") || die;
	while (<CFG>)
	{
		chomp;
		if (m/^$option\s*=\s*"?(\S+)"?/)
		{
			$optval = $1;
		}
		if (m/^TODO_DIR\s*=\s*"?(\S+)"?/)
		{
			$TODO_DIR = $1;
		}
	}
	close CFG;
	unless (defined $optval)
	{
		return undef;
	}

	$optval =~ s/\$TODO_DIR/$TODO_DIR/;
	$optval =~ s/\$HOME/$HOMEDIR/;
	$optval =~ s/\"//g;
	return $optval;
}

sub todotxt_get_file_path
{
	return todotxt_get_cfg_option("TODO_FILE");
}

1;
