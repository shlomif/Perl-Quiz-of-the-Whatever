package Assign;

use strict;

require Exporter;

use vars qw(@ISA @EXPORT);

@ISA=qw(Exporter);

@EXPORT = qw(allocate_minimal_rooms);

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->_init();
    return $self;
}

sub _init
{
    return 0;
}

sub get_params_from_file
{
    my $self = shift;
    
    my $in_file = shift;
    
    local (*I);
    open I, "<$in_file" || die "Could not open file for reading";
    my $line = <I>;
    chomp($line);
    my ($classes_num, $time_slots_num) = split(/\s+/, $line);
    my @table;
    for my $i (1 .. $classes_num)
    {
        $line = <I>;
        chomp($line);
        if (length($line) ne $time_slots_num)
        {
            die "Wrong number of characters in line " . ($i+1);
        }
        my $is_assigned_once = 0;
        my @time_slots;
        foreach my $c (split(//, $line))
        {
            my $is_true = ($c ne " ");
            if ($is_true)
            {
                $is_assigned_once = 1;
            }
            push @time_slots, $is_true;
        }
        if (! $is_assigned_once)
        {
            die "Class has no allocated time slots in line " . ($i+1) . ".";
        }
        push @table, \@time_slots;
    }

    return ($classes_num, $time_slots_num, \@table);
}

sub gen_classes_collision_table
{
    my $self = shift;

    my $classes_num = $self->{'c_n'};
    my $time_slots_num = $self->{'ts_n'};

    my $hours_table = $self->{'table'};

    my $collision_table = 
        [ map { [ (0) x $classes_num ] } (1 .. $classes_num)]
        ;

    for my $ts (0 .. ($time_slots_num - 1))
    {
        for my $c1 (0 .. ($classes_num-2))
        {
            next if ($hours_table->[$c1]->[$ts] == 0);
            
            for my $c2 (($c1+1) .. ($classes_num-1))
            {
                next if ($hours_table->[$c2]->[$ts] == 0);
                $collision_table->[$c1]->[$c2] = 1;
                $collision_table->[$c2]->[$c1] = 1;
            }
        }
    }
    $self->{'classes_collision_table'} = $collision_table;
}

sub assign_params
{
    my $self = shift;
    my ($classes_num, $time_slots_num, $table) = @_;
    
    $self->{'c_n'} = $classes_num;
    $self->{'ts_n'} = $time_slots_num;    
    $self->{'table'} = $table;

    $self->gen_classes_collision_table();

    return 0;
}

sub read
{
    my $self = shift;

    my $in_file = shift;

    return 
        $self->assign_params(
            $self->get_params_from_file($in_file)
        );
}

use constant NONE => 0;
use constant ASSIGNED => 1;
use constant CANNOT => 2;

sub solve_for_teachers_num
{
    my $self = shift;

    my $teachers_num = shift;

    my $classes_num = $self->get_classes_num();
    my $time_slots_num = $self->{'ts_n'};
    my $collision_table = $self->{'classes_collision_table'};

    # A trivial case for assignment
    if ($teachers_num >= $classes_num)
    {
        return [ 0 .. ($classes_num-1) ];
    }

    my $assign_first_flag = 1;
    if (@_)
    {
        $assign_first_flag = 0;
    }

    # This maintains a truth table of which teacher
    # can or cannot teach which class.
    my $truth_table = shift ||
        [ 
            map { [ (NONE) x $classes_num ] } (1 .. $teachers_num) 
        ];

    # This is a bitmask that indicates which classes are going to
    # be assigned a teacher for and which already were assigned.
    my $class_bitmask = shift || [(0) x $classes_num];

    my $assign_class_teacher = sub {
        my $class = shift;
        my $teacher = shift;

        for my $t (0..($teachers_num-1))
        {
            $truth_table->[$t]->[$class] = 
                (($t == $teacher) ? 
                    ASSIGNED :
                    CANNOT
                );
        }

        for my $c (0 .. ($classes_num-1))
        {
            if ($collision_table->[$c]->[$class])
            {
                $truth_table->[$teacher]->[$c] = CANNOT;
            }
        }
        $class_bitmask->[$class] = 1;
    };
    
    if ($assign_first_flag)
    {
        $assign_class_teacher->(0,0);
    }

    my $num_assigned_teachers = shift || 1;

    TEACHERS_ASSIGNMENT_LOOP_1:
    while ($num_assigned_teachers < $teachers_num)
    {
        # Find a class that has to be assigned a new teacher
        my $suitable_class;
        CLASS_LOOP: for my $class (0 .. ($classes_num-1))
        {
            # This class was already assigned so there's no need
            # to check it again.        
            next if $class_bitmask->[$class];
            for my $t (0 .. ($num_assigned_teachers - 1))
            {
                if ($truth_table->[$t]->[$class] != CANNOT)
                {
                    next CLASS_LOOP;
                }
            }
            # We found a suitable class.
            $suitable_class = $class;
            last CLASS_LOOP;
        }
        if (defined($suitable_class))
        {
            $assign_class_teacher->(
                $suitable_class, 
                $num_assigned_teachers++
                );
        }
        else
        {
            last TEACHERS_ASSIGNMENT_LOOP_1;
        }
    }
    
    if ($num_assigned_teachers == $teachers_num)
    {
        my $class=0;
        my $run_first = 1;
        while ($run_first || ($class < $classes_num))
        {
            $run_first = 0;
            CLASS_ASSIGN_SINGULAR_TEACHER_LOOP:
            for($class=0;$class < $classes_num; $class++)
            {
                # This class was already assigned so there's no need
                # to check it again.
                next if ($class_bitmask->[$class]);
                my $teachers_count = 0;
                my $available_teacher;
                for my $t (0 .. ($teachers_num-1))
                {
                    if ($truth_table->[$t]->[$class] == NONE)
                    {
                        $teachers_count++;
                        $available_teacher = $t;
                    }
                }
                if ($teachers_count == 1)
                {
                    $assign_class_teacher->(
                        $class,
                        $available_teacher
                        );
                    last CLASS_ASSIGN_SINGULAR_TEACHER_LOOP;
                }
            }
        }
    }

    my $class_to_iterate_over;
    for($class_to_iterate_over=0;
        $class_to_iterate_over<$classes_num;
        $class_to_iterate_over++)
    {
        last if (! $class_bitmask->[$class_to_iterate_over]);
    }

    if ($class_to_iterate_over == $classes_num)
    {
        return $self->create_summary($truth_table);
    }
    
    my @teachers =
        (grep
            { $truth_table->[$_]->[$class_to_iterate_over] == NONE }
            (0 .. ($teachers_num-1))
        );

    # Save a backup copy.
    my $backup_truth_table = $truth_table;
    my $backup_class_bitmask = $class_bitmask;

    foreach my $iter_teacher (@teachers)
    {
        # Duplicate
        $truth_table = [ map { [ @$_ ] } @$backup_truth_table ];
        $class_bitmask = [ @$backup_class_bitmask ];
        
        $assign_class_teacher->($class_to_iterate_over, $iter_teacher);
        
        my $ret = 
            $self->solve_for_teachers_num(
                $teachers_num,
                $truth_table,
                $class_bitmask,
                $num_assigned_teachers
                );
        if ($ret)
        {
            return $ret;
        }
    }

    return undef;
}

sub create_summary
{
    my $self = shift;

    my $truth_table = shift;

    my $classes_num = $self->get_classes_num();

    return
        [
            map
                {
                    my $c = $_;
                    (grep
                        {
                            $truth_table->[$_]->[$c] == ASSIGNED
                        }
                        (0..(scalar(@$truth_table)-1))
                    )
                }
                (0 .. ($classes_num-1))
        ];                
}

sub solve
{
    my $self = shift;

    my $teachers_num = $self->get_classes_num();
    my ($ret, $prev_ret);

    while ($teachers_num >= 1)
    {
        $ret = $self->solve_for_teachers_num($teachers_num);
        last if (!$ret);
        $teachers_num--;
        $prev_ret = $ret;
    }

    return $prev_ret;
}

sub get_classes_num
{
    my $self = shift;

    return $self->{'c_n'};
}

sub allocate_minimal_rooms
{
    my ($classes_num, $time_slots_num, $schedule) = (@_);
    my $obj = Assign->new();

    $obj->assign_params($classes_num, $time_slots_num, $schedule);

    return $obj->solve();
}

1;
