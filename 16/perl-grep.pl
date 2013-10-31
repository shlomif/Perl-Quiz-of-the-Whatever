#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;

sub process_command_line_arguments
{
    # Process the command line arguments
    my $display_line_num = 0;
    my $recursive = 0;
    my $case_insensitive = 0;
    my $result = 
        GetOptions(
            'n|line-number' => \$display_line_num,
            'r|R|recursive' => \$recursive,
            'i|ignore-case' => \$case_insensitive,
        );

    if (! $result)
    {
        die "Command line could not be processed."
    }

    my $pattern_text = shift(@ARGV);
    if (!defined($pattern_text))
    {
        die "No pattern given at the command line."
    }
    my $pattern =
        ($case_insensitive ?
            (qr/$pattern_text/i) :
            (qr/$pattern_text/)
        );

    my $dir = shift(@ARGV);
    if (!defined($dir))
    {
        die "No directory to search given at the command line."
    }
    return 
        (
            'dir' => $dir, 
            'pattern' => $pattern,
            'display_line_num' => $display_line_num,
            'recursive' => $recursive,
            'case_insensitive' => $case_insensitive,
        );
}

my @args = process_command_line_arguments();

search_dir(
    @args,
    );

# TODO :
# Implement the search without procedural recursion.

sub search_dir
{
    my %args = (@_);

    my $dir = $args{dir};
    my $recursive = $args{recursive};

    my ($dir_handle);
    (opendir $dir_handle, $dir) || 
        die "Cannot open directory! $!";

    my @files = readdir($dir_handle);

    # Sort @files alphabeticallly so the order will be constant
    @files = (sort { $a cmp $b } @files);
    
    closedir($dir_handle);

    my $full_path;

    FILES_IN_DIR_LOOP:
    foreach my $filename (@files)
    {
        if (($filename eq ".") || ($filename eq ".."))
        {
            next FILES_IN_DIR_LOOP;
        }
        # TODO : Use File::Spec ?
        $full_path = "$dir/$filename";

        if (-f $full_path)
        {
            search_file(%args, 'full_path' => $full_path);
        }
        elsif (-d $full_path)
        {
            if ($recursive)
            {
                search_dir(%args, 'dir' => $full_path);
            }
        }
    }
}

sub search_file
{
    my %args = (@_);

    my $file_handle;
    my $full_path = $args{full_path};
    my $pattern = $args{pattern};
    my $display_line_num = $args{display_line_num};
    my $case_insensitive = $args{case_insensitive};
    
    open $file_handle, ("<".$full_path)
        or return;
    my $line_num = 1;
    my $line;
    while (defined($line = <$file_handle>))
    {
        chomp($line);
        # TODO: Add pattern verification
        if ($line =~ /$pattern/)
        {
            print "${full_path}:";
            if ($display_line_num)
            {
                print "${line_num}:";
            }            
            print $line;
            print "\n";
        }
    }
    continue
    {
        $line_num++;
    }
    close ($file_handle);
}
