#!/usr/bin/perl
#
# Search Automation for microbenchmark for Tail Latency Porject
# Heng Zhuo, April/2021
# Adopted from Gokul's scripts, original info:
# Script to update microbench config/creation file - used for the design space project
# Gokul Subramanian Ravi, 5/28/2019
#
#
#
use warnings; use strict;
use Getopt::Long;
use Pod::Usage;
use List::Util qw[min max]; #for min/max
use JSON;

my $rundir_wkld = "/research/sgokul/MicroProbe/m20out_gcc_test_wkld/";
my $runfile_wkld = "";
my $output_file_wkld = "/research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt";

my $benchmark_path = "/home/zohan/microbench/microbench/";
my $template_script   = "/home/zohan/microbench/microbench/template.sh";
my $gen_script   = "/home/zohan/microbench/microbench/microbench-run-autogen.sh";

my $output_dir = "/home/zohan/microbench/microbench/results-autogen/sample/";

#Parameters
my $MICRO_nonBlockT;
my $MICRO_nonBlockV;
my $MICRO_blockT;
my $MICRO_blockV;
my $MICRO_sTime;
my $MICRO_sProb;
my $MICRO_lowBound;
my $MICRO_highBound;
my $MICRO_noiseT;
my $MICRO_noiseP;
my $MICRO_noiseV;
my $MICRO_spinL;

my @target_array = (0, 0, 0, 0, 0, 0);
my @target_array_norm = (-1, -1, -1, -1, -1, -1);
my @target_array_max = (1, 1, 1, 1, 1, 1, 1);
my @target_array_min = (0, 0, 0, 0, 0, 0, 0);
my $target_num = 3;

my @knob_array = (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
my @knob_array_actual = (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
my @knob_ansatz = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

my $knob_range = 10;
my $knob_num = 12;


#Arrays for Parameters - array length has to equal $knob_range
my @ARRAY_nonBlockT = qw{800 900 1000 1100 1200 1300 1400 1500 1600 1700};
my @ARRAY_nonBlockV = qw{10 10 10 10 10 10 10 10 10 10}; # fixed 10
my @ARRAY_blockT = qw{1 1 1 1 1 1 1 1 1 1}; # fixed 1
my @ARRAY_blockV = qw{100 100 100 100 100 100 100 100 100 100}; # fixed 100
my @ARRAY_sTime = qw{20000 25000 30000 35000 40000 45000 50000 55000 60000 65000};
my @ARRAY_sProb = qw{1 2 3 4 5 6 7 8 9 10};
my @ARRAY_lowBound = qw{0 0 0 0 0 0 0 0 0 0}; # fixed 0
my @ARRAY_highBound = qw{0 0 0 0 0 0 0 0 0 0}; # fixed 0
my @ARRAY_noiseT = qw{2000 2500 3000 3500 4000 4500 5000 5500 6000 6500};
my @ARRAY_noiseP = qw{20 25 30 35 40 45 50 55 60 65};
my @ARRAY_noiseV = qw{10 10 10 10 10 10 10 10 10 10};
my @ARRAY_spinL = qw{200 200 200 200 200 200 200 200 200 200}; # fixed 200

#Index for Parameter Arrays
my $Index_nonBlockT = int(rand($knob_range));
my $Index_nonBlockV = int(rand($knob_range));
my $Index_blockT = int(rand($knob_range));
my $Index_blockV = int(rand($knob_range));
my $Index_sTime = int(rand($knob_range));
my $Index_sProb = int(rand($knob_range));
my $Index_lowBound = int(rand($knob_range));
my $Index_highBound = int(rand($knob_range));
my $Index_noiseT = int(rand($knob_range));
my $Index_noiseP = int(rand($knob_range));
my $Index_noiseV = int(rand($knob_range));
my $Index_spinL = int(rand($knob_range));

#Step 0: active uprobe
print "R-E-L-A-X\n";


#Step 1: nun simpoint of workload of interest (need to do this each time, since we are getting workload dependent stats, assuming that the prescribed uarch can change)
run_wkld();


#Step2: Collect stats of interest and store them in some global variable. Current stats are: IPC, L1 miss rate, L2 miss rate, Mispred
wkld_collect_stats();

#Step 2.5 - for all the direct knobs 'uarch indep', set those values first
ansatz();

#Step3: Run grad (or others) to create the synthetic workload to reduce loss function 
grad();
# greedy();


#Step4: Print final results
conclusion();

# system("exit");

# system("ls");
exit;

###### end of 'main'



#Below are all the subs
sub run_wkld{
    
	print "Readyyyyyyyyyy UP!\n";
    # no need for microbench, use pregenerated tailbench output
    # but rerun python parse results
	# system("rm -rf $rundir_wkld");
	# print "Watch this!!\n";


}#run_wkld

sub wkld_collect_stats{

	# if (-e $output_file_wkld) {
	# 	print "File exists!\n";
	# 	if(-s $output_file_wkld > 0){
	# 		print "File has reasonable size!\n";
			
    # round mean: 3.986 ms | 95th: 18.277 ms (12.003 ms) | 99th: 25.435 ms (21.752 ms) | service mean: 0.676 ms | 95th: 0.946 ms (0.781 ms) | 99th: 1.405 ms (0.906 ms)
    #In all correcting for ops

    $target_array[0] = 16.404; 
    $target_array[1] = 198.202;
    $target_array[2] = 360.432;
    $target_array[3] = 0.687;
    $target_array[4] = 0.959;
    $target_array[5] = 1.379;


    print "Target Stats: mean: $target_array[0] , 95th: $target_array[1] , 99th: $target_array[2]; service mean: $target_array[3] , 95th: $target_array[4] , 99th: $target_array[5].\n";

	# 	}
	# 	else{ print "File has almost zero size!\n";}
	# }
	# else{ print "File does not exist!\n";}


    #Normalize all values
    #TODO - Normalizing to target values - these are just becoming 1
    for(my $n=0; $n<$target_num; $n++){
        $target_array_max[$n] = $target_array[$n];#New
        $target_array_min[$n] = 0;
        $target_array_norm[$n]= 1;# not really being used in this one
    }

    # print "Target Norm Truth Stats mean: $target_array_max[0] , 95th: $target_array_max[1] , 99th: $target_array_max[2]; service mean: $target_array_max[3] , 95th: $target_array_max[4] , 99th: $target_array_max[5].\n";

}#wkld_collect_stats

sub ansatz {

    #Knob indices
    #	$nonblockT = $[0];
    #	$nonblockV = $[1];
    #	$blockT = $[2];
    #	$blockV = $[3];
    #	$STIME = $[4];
    #	$SPROB = $[5];
    #	$lowbound =$[6];
    #	$highbound =$[7];
    #	$NOISETIME = $[8];
    #	$NOISEPROB = $[9];
    #	$NOISEVAR = $[10];
    #   $spinL = $[11];

    #Do variable by variable assignment
    # $knob_array_actual[0] =  ($knob_range - 1) * $wkld_array[0];
    # $knob_array[0] = int($knob_array_actual[0]+0.5);
    # $knob_array[0] = 5;
    # $knob_ansatz[0] = 0;

    $knob_array[1] = 0;
    $knob_ansatz[1] = 1;

    $knob_array[2] = 0;
    $knob_ansatz[2] = 1;

    $knob_array[3] = 0;
    $knob_ansatz[3] = 1;

    # $knob_array[4] = 0;
    # $knob_ansatz[4] = 1;

    $knob_array[5] = 0;
    $knob_ansatz[5] = 1;

    $knob_array[6] = 0;
    $knob_ansatz[6] = 1;

    $knob_array[7] = 0;
    $knob_ansatz[7] = 1;

    # $knob_array[8] = 0;
    # $knob_ansatz[8] = 1;

    $knob_array[9] = 0;
    $knob_ansatz[9] = 1;

    $knob_array[10] = 0;
    $knob_ansatz[10] = 1;

    $knob_array[11] = 0;
    $knob_ansatz[11] = 1;

} #ansatz



sub loss_function{

    my ($ref_predicted_array) = @_;
    my @predicted_array = @{$ref_predicted_array};
    my @predicted_array_norm;

    #Normalize all values
    # print "normalized predict-target diff:\n";
    for(my $n=0; $n<$target_num; $n++){
        $predicted_array_norm[$n]= ($predicted_array[$n] - $target_array_min[$n])/($target_array_max[$n] - $target_array_min[$n]);
        #new - based on how we updated the target normalizaiton, all this is doing is normalizing to workld
        # print "$n: $predicted_array_norm[$n], $predicted_array[$n], $target_array_max[$n]\n";
        # printf " [%.1d]: %.3f, %.3f, %.3f\n", $n, $predicted_array_norm[$n], $predicted_array[$n], $target_array_max[$n];  # prints "<1.0>"
    }

    # print "Syn: Norm Predicted Stats: mean: $predicted_array_norm[0] , 95th: $predicted_array_norm[1] , 99th: $predicted_array_norm[2].\n";

    #Step a: Caclulate MSE using log (for now) 
    my $sum = 0;
    my $count = 0;

    print "Calculating Loss (using log): \n";

    for(my $n=0; $n<$target_num ; $n++){

        my $log_val = log($predicted_array_norm[$n]);
        printf " %.3f <- %.3f, ", $log_val, $predicted_array_norm[$n];
        # print "($predicted_array_norm[$n] , $target_array_norm[$n]), log is $log_val";
        $sum = $sum + abs($log_val);
        $count++;
    }

    my $mean = $sum/$count;

    print "\nLoss - MSE: $mean\n";

    return $mean;

}#loss_function


sub conclusion {
    print "testing run finished.\n";
    my $output_index=$knob_array[0];
    printf "Output value using: %d. \n", $ARRAY_nonBlockT[$knob_array[0]];

    print "Target Stats: mean: $target_array[0] , 95th: $target_array[1] , 99th: $target_array[2]; service mean: $target_array[3] , 95th: $target_array[4] , 99th: $target_array[5].\n";
}#conclusion

sub grad {
    #GOKUL-3: grad

    # 0) Parameters
    my $var_size = $knob_num;
    my $stop = 0;
    my $grad_itn = 0;
    my $max_itn = 20;#TODO 50
    my $first = 1;
    my $overall_itn=0;

    while ($stop !=1){

        # a) Start from fixed
        if($first == 1){
            $first = 0;
            for(my $j=0; $j < $var_size; $j=$j+1){
                if(!$knob_ansatz[$j]){ #This is not an ansatz
                    #$knob_array_actual[$j] = 5;
                    $knob_array_actual[$j] = int(rand($knob_range));
                    $knob_array[$j] = int($knob_array_actual[$j]+0.5);
                }
            }
        }


        #b) calculate metric_old
        $overall_itn = $overall_itn + 1;
        my $metric_old = work(\@knob_array,$overall_itn);
        my $loss_old = 1.0/$metric_old; 
        printf "Old METRIC: %.3f, LOSS: %.3f, ", $metric_old, $loss_old;
        # print "Value of knobs :";
        for(my $n=0; $n < $knob_num ; $n = $n + 1){
            if(!$knob_ansatz[$n]){ #This is not an ansatz
                printf "knob value: %.3f.;", $ARRAY_nonBlockT[$knob_array_actual[$n]];
            }
        }
        print "....\n";

        my @metric_array =      (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        my @step_array =        (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        my @grad_array =        (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        my @grad_array_norm =   (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        my $grad_max_index = 0;

        #c) perturb each knob and calculate metric at each and the gradients
        for(my $i = 0; $i < $var_size; $i=$i+1){
            if(!$knob_ansatz[$i]){ #This is not an ansatz

                #stochasticity, ignore for now, always do
                my $do = 1;
                # my $threshold = 50/(1+$grad_itn); #TODO give legit value if you want stochasticity - can make this dependent on itn (sim annealing?)
                # my $randesh = int(rand(100));
                # if($randesh < $threshold){
                #     $do = 0;
                # }
                if($do==1){
                    
                    # Step value for this itn (adaptive)
                    # starting at step size of 3, when itreration number goes up,
                    # decrese the step size to a min of 1
                    my $step_curry = (3-int($grad_itn/10));	
                    if($step_curry <= 0){
                        $step_curry=1;
                    }
                    
                    #This is for both up and down
                    my $metric_up = 0;
                    my $metric_down = 0;
                    my $knob_old = 0;

                    #Upwards	
                #	if($knob_array[$i] < $knob_range - 1) {
                    $knob_old = $knob_array[$i];
                    $knob_array[$i] = min(($knob_array[$i]+$step_curry), ($knob_range-1));
                    $overall_itn = $overall_itn + 1;
                    $metric_up = work(\@knob_array,$overall_itn);
                    $knob_array[$i] = $knob_old; # Putting it back as before
                #	}
                    
                    #Downwards	
                #	if($knob_array[$i] > 0) {
                    $knob_old = $knob_array[$i];
                    $knob_array[$i] = max(($knob_array[$i]-$step_curry), (0));
                    $overall_itn = $overall_itn + 1;
                    $metric_down = work(\@knob_array,$overall_itn);
                    $knob_array[$i] = $knob_old; # Putting it back as before
                #	}

                    #Use one of the 2
                    if($metric_up >= $metric_down){ 
                        $metric_array[$i] = $metric_up;
                        $step_array[$i] = 1*$step_curry;
                    }
                    else{
                        $metric_array[$i] = $metric_down;
                        $step_array[$i] = -1*$step_curry;
                    }


                    $grad_array[$i] = ($metric_array[$i] - $metric_old); #TODO should this be multiplied by the grad? 
                    if($grad_array[$i] < 0) {$grad_array[$i] = 0;} #TODO - new addition which is valid only for up+down
                    if(($grad_array[$i]) >= ($grad_array[$grad_max_index])) { #TODO using absolute val
                        $grad_max_index = $i;
                    }
                }#do
            }#ansatz
        }

        #d) normalize grad_array and update actual knob array
        for(my $i = 0; $i < $var_size; $i=$i+1){
            if(!$knob_ansatz[$i]){ #This is not an ansatz
                if($grad_array[$i] > 0){
                    if($grad_array[$grad_max_index] > 0){
                        $grad_array_norm[$i] = 1.0*$grad_array[$i]/abs($grad_array[$grad_max_index]); #TODO This is all gonna be fractional. Step size is 1
                    }
                    else {
                        $grad_array_norm[$i] = $grad_array[$i]; #In this case, all must be 0
                    }
                }
                else{
                	$grad_array_norm[$i]=0;
                }
                $knob_array_actual[$i] = $knob_array_actual[$i] + $grad_array_norm[$i]*$step_array[$i];
                if($knob_array_actual[$i] > $knob_range - 1) {
                    $knob_array_actual[$i] = $knob_range - 1;
                }
                if($knob_array_actual[$i] < 0) {
                    $knob_array_actual[$i] = 0;
                }
                
            }#ansatz
        }

        #e) Usable knob array
        for(my $i = 0; $i < $var_size; $i=$i+1){
            if(!$knob_ansatz[$i]){ #This is not an ansatz
                # my $quant_val =  100.0*($knob_array_actual[$i] - int($knob_array_actual[$i]));
                # my $rand = int(rand(100));
                # if($rand < $quant_val){
                #     $knob_array[$i] = int($knob_array_actual[$i]) + 1;
                #     if($knob_array[$i] > $knob_range - 1) {
                #         $knob_array[$i] = $knob_range - 1;
                #     }
                # }
                # else{
                #     $knob_array[$i] = int($knob_array_actual[$i]);
                # }
                
                $knob_array[$i] = int($knob_array_actual[$i] + 0.5); #TODO use this instead of above if you want gradual instead of lottery

                $knob_array_actual[$i] = $knob_array[$i]; #TODO - what this does is it makes changes per iteration more smooth - this is a bit convoluted way of doing things but at least it remains plug and play

            }#ansatz
        }


        # f) repeat, but stop at some point
        # set by max_itn, max iteration
        $grad_itn = $grad_itn+1;
        if($grad_itn >= $max_itn){
                $stop=1;
        }

        print "Value of updated knobs :";
        for(my $n=0; $n < $knob_num ; $n = $n + 1){
            if(!$knob_ansatz[$n]){ #This is not an ansatz
                printf "knob value: %.3f.\n", $ARRAY_nonBlockT[$knob_array_actual[$n]];
                print $knob_array_actual[$n];
            }
        }
        
    }
} # grad


sub work  { 
    #$side = $_[0]; 

	my $val = -1;
	my $power_val;
	my ($ref_input_array, $itn) = @_;
	my @ubench_array = (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);

	# $itn = $itn + $start;
    $itn = $itn + 0;
	my @input_array = @{$ref_input_array};
	print "\nValue of itn is:";
	print $itn;
	print "\nValue of vals is:";
	for(my $n=0; $n < $knob_num ; $n = $n + 1){
		print $input_array[$n];
		print ","
	}
	print "....\n";
	$Index_nonBlockT = $input_array[0];
	$Index_nonBlockV = $input_array[1];
	$Index_blockT = $input_array[2];
	$Index_blockV = $input_array[3];
	$Index_sTime = $input_array[4];
	$Index_sProb = $input_array[5];
	$Index_lowBound =$input_array[6];
	$Index_highBound =$input_array[7];
	$Index_noiseT = $input_array[8];
	$Index_noiseP = $input_array[9];
	$Index_noiseV = $input_array[10];

	$MICRO_nonBlockT = $ARRAY_nonBlockT[$Index_nonBlockT];      
	$MICRO_nonBlockV = $ARRAY_nonBlockV[$Index_nonBlockV];
	$MICRO_blockT = $ARRAY_blockT[$Index_blockT];
	$MICRO_blockV = $ARRAY_blockV[$Index_blockV];
	$MICRO_sTime = $ARRAY_sTime[$Index_sTime];
	$MICRO_sProb = $ARRAY_sProb[$Index_sProb];
	$MICRO_lowBound = $ARRAY_lowBound[$Index_lowBound];
	$MICRO_highBound = $ARRAY_highBound[$Index_highBound];
	$MICRO_noiseT = $ARRAY_noiseT[$Index_noiseT];
	$MICRO_noiseP = $ARRAY_noiseP[$Index_noiseP];
	$MICRO_noiseV = $ARRAY_noiseV[$Index_noiseV];
    $MICRO_spinL = $ARRAY_spinL[$Index_spinL];
    # my $output_dir = "/home/zohan/microbench/microbench/results-autogen/sample/";

    printf "Replacing: MICRO_nonBlockT-> %d\n", $MICRO_nonBlockT;
    printf "Replacing: MICRO_sTime-> %d\n", $MICRO_sTime;
    printf "Replacing: MICRO_noiseT-> %d\n", $MICRO_noiseT;

	# print "Going to location 1...\n";
	chdir($benchmark_path);
	system("cp $template_script $gen_script");

	system("sed -i 's/MICRO_nonBlockT/$MICRO_nonBlockT/g' $gen_script");
	system("sed -i 's/MICRO_nonBlockV/$MICRO_nonBlockV/g' $gen_script");
	system("sed -i 's/MICRO_blockT/$MICRO_blockT/g' $gen_script");
	system("sed -i 's/MICRO_blockV/$MICRO_blockV/g' $gen_script");
	system("sed -i 's/MICRO_sTime/$MICRO_sTime/g' $gen_script");
	system("sed -i 's/MICRO_sProb/$MICRO_sProb/g' $gen_script");
	system("sed -i 's/MICRO_lowBound/$MICRO_lowBound/g' $gen_script");
	system("sed -i 's/MICRO_highBound/$MICRO_highBound/g' $gen_script");
	system("sed -i 's/MICRO_noiseT/$MICRO_noiseT/g' $gen_script");
	system("sed -i 's/MICRO_noiseP/$MICRO_noiseP/g' $gen_script");
	system("sed -i 's/MICRO_noiseV/$MICRO_noiseV/g' $gen_script");
    system("sed -i 's/MICRO_spinL/$MICRO_spinL/g' $gen_script");
    # system("sed -i 's/MICRO_output/$output_dir/g' $gen_script");
    
    # run the microbench with new knobs
	# system("rm -rf $rundir");
	system("bash $gen_script");

	print "Syn: Done Done-a Done!\n";


    my $file = '/home/zohan/microbench/microbench/results-autogen/sample/1200/data.json';
    my $py_script = '/home/zohan/microbench/utilities/parsefolder.py';
    # system("python3 $py_script /home/zohan/microbench/microbench/results-autogen/sample/1200/lats-1.bin");
    system("python3 $py_script");
    # read in json from Python
    my $json;
    {
        local $/;
        open my $fh, '<', $file or die $!;
        $json = <$fh>;
        close $fh;
    }

    # decode the Python tuple into a Perl array (reference) from the JSON string
    my $array = decode_json $json ;
    print "parse lats results: ";
    for my $elem (@$array){
        printf "%.3f | ", $elem;
    }
    print "\n";
    # my $ubench_array = $array;

	$val = (1.0/loss_function(\@$array));
    # $val = 0;

	return $val; #TODO returned value is maximized. So to minimize loss, we should max 1/loss. so val is 1/loss
} #work 


__END__


