#!/usr/bin/perl -w

use strict;

use Mail::Box;
use Mail::Box::MH;
use Getopt::Long;

my $field = "subject";
my $reverse = 0;

my $result = GetOptions("f" => \$field, "r" => \$reverse);

my $dir_path = shift || "$ENV{HOME}/Mail/inbox";
my $folder = Mail::Box::MH->new('folder' => $dir_path);

my $idx = 0;
my @messages;




while (my $msg = $folder->message($idx++))
{
    # print $msg->messageId(), "\n";
    my $filename = $msg->filename();
    $filename =~ /\/([^\/]*)$/;
    $filename = $1;
    my $f;
    if ($field eq "from")
    {
        $f = $msg->from();
    }
    elsif ($field eq "to")
    {
        $f = $msg->to();
    }
    else
    {
        $f = $msg->subject();
    }
    push @messages, { 'filename' => $filename, 'field' => $f };
}

undef($folder);

my @sorted_indexes = 
    sort { 
        ($messages[$a]->{'field'} cmp $messages[$b]->{'field'}) || 
        ($a <=> $b)
    } (0 .. $#messages);

if ($reverse)
{
    @sorted_indexes = reverse(@sorted_indexes);
}

my @messages_moved = (0) x @messages;

my $temp_filename = "a6Hy0";
while (-e "$dir_path/$temp_filename")
{
    $temp_filename++;
}

my $i;
chdir($dir_path);

sub myrename
{
    my ($from, $to) = @_;
    print "Renaming $from to $to\n";
    rename($from, $to);
}

for($i=0;$i<@messages;$i++)
{
    if (!$messages_moved[$i])
    {
        # Check if we move the message to itself
        # if so - do nothing except mark this message
        # as moved
        if ($sorted_indexes[$i] == $i)
        {
            $messages_moved[$i] = 1;
        }
        else
        {
            myrename($messages[$i]->{'filename'}, $temp_filename);
            my ($prev_idx, $next_idx);
            $prev_idx = $i;
            $next_idx = $sorted_indexes[$prev_idx];
            while ($next_idx != $i)
            {
                myrename(
                    $messages[$next_idx]->{'filename'}, 
                    $messages[$prev_idx]->{'filename'}
                );
                $messages_moved[$prev_idx] = 1;
                $prev_idx = $next_idx;
                $next_idx = $sorted_indexes[$prev_idx];
            }
            $messages_moved[$prev_idx] = 1;
            myrename($temp_filename, $messages[$prev_idx]->{'filename'});
        }
    }
}

