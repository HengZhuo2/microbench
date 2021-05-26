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

#Reconfigurable script knobs
#1) m*out
#3) riscv_flex_v*
#4) riscv_template_slim.py flex_v outdir
#6) Create flex_v dir
#7) Create build dir
#8) Update Makefile in build


my $rundir_wkld = "/research/sgokul/MicroProbe/m20out_gcc_test_wkld/";
my $runfile_wkld = "";
my $output_file_wkld = "/research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt";
my $location1 = "/research/sgokul/MicroProbe_July2020/microprobe/targets/riscv/examples/";
my $file_name   = "riscv_flex_gcc.py";
my $template_name   = "riscv_template_slim.py";
my $location2 = "/research/sgokul/MicroProbe_July2020/microprobe/targets/riscv/examples/build_flex_gcc/";
my $makefile = "Makefile";
my $runfile = "/research/sgokul/MicroProbe_July2020/microprobe/targets/riscv/examples/build_flex_gcc/riscv_flex_gcc/riscv_new-p-gokul_";
my $stat = "ipc_total";
my $location3 = "/research/sgokul/MicroProbe/";
my $location4 = "/research/sgokul/gem5-mcpat/gem5-mcpat-parser/";
my $output_file = "/research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt";
my $rundir = "/research/sgokul/MicroProbe/m20out_gcc_test_ubench/";
# my $wkld_maxinsts = 10000000;
# my $ubench_maxinsts = 10000000;

# my $start = 69000000;

#Parameters
my $GOK_ADD;
my $GOK_MUL;
my $GOK_FADDS;
my $GOK_FMULS;
my $GOK_FADDD;
my $GOK_FMULD;
my $GOK_REG_DIST;
my $GOK_ILP_DIST;
my $GOK_BEQ;
my $GOK_BNE;
my $GOK_FLD;
my $GOK_FLW;
my $GOK_LB;
my $GOK_LD;
my $GOK_LW;
my $GOK_FSD;
my $GOK_FSW;
my $GOK_SB;
my $GOK_SD;
my $GOK_SW;
my $GOK_MEM_SIZE;
my $GOK_MEM_STRIDE;
my $GOK_MEM2_SIZE;
my $GOK_MEM2_STRIDE;
my $GOK_MEM_RATIO;
my $GOK_MEM_TEMP_X;
my $GOK_MEM_TEMP_Y;
my $GOK_MEM2_TEMP_X;
my $GOK_MEM2_TEMP_Y;
my $GOK_BRANCH_RAND;


my @wkld_array = (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
my @wkld_array_norm = (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
my @wkld_index_interest = (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
my @knob_array = (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
my @knob_array_actual = (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
my @knob_ansatz = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
my @wkld_array_max = (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
my @wkld_array_min = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
my $knob_range = 25;
my $knob_num = 30;

#Arrays for Parameters - array length has to equal $knob_range
my @ARRAY_ADD = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_MUL = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_FADDS = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_FMULS = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_FADDD = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_FMULD = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_REG_DIST = qw{1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25};
my @ARRAY_ILP_DIST = qw{1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25};
my @ARRAY_BEQ = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_BNE = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_FLD = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_FLW = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_LB = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_LD = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_LW = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_FSD = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_FSW = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_SB = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_SD = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_SW = qw{0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
my @ARRAY_MEM_SIZE = qw{16*2*1024 20*2*1024 24*2*1024 28*2*1024 32*2*1024 40*2*1024 48*2*1024 56*2*1024 64*2*1024 80*2*1024 96*2*1024 112*2*1024 128*2*1024 144*2*1024 160*2*1024 192*2*1024 224*2*1024 256*2*1024 320*2*1024 384*2*1024 448*2*1024 512*2*1024 640*2*1024 768*2*1024 1024*2*1024};#Gonna keep this fixed at 8kB so that accesses within this can all benefit from locality/hits - fake add to ansatz and directly incorporate into template TODO
my @ARRAY_MEM_STRIDE = qw{4 8 12 16 20 24 32 40 48 56 64 80 96 112 128 144 160 192 256 320 384 512 640 768 1024};
my @ARRAY_MEM2_SIZE = qw{16*2*1024 20*2*1024 24*2*1024 28*2*1024 32*2*1024 40*2*1024 48*2*1024 56*2*1024 64*2*1024 80*2*1024 96*2*1024 112*2*1024 128*2*1024 144*2*1024 160*2*1024 192*2*1024 224*2*1024 256*2*1024 320*2*1024 384*2*1024 448*2*1024 512*2*1024 640*2*1024 768*2*1024 1024*2*1024};#Max mem size should be 2MB / min should be roughly cache size
my @ARRAY_MEM2_STRIDE = qw{4 8 12 16 20 24 32 40 48 56 64 80 96 112 128 144 160 192 256 320 384 512 640 768 1024};
my @ARRAY_MEM_RATIO = qw{4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 99}; #Note  they need some twiddlingg
my @ARRAY_MEM_TEMP_X = qw{1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25}; #qw{4 8 12 16 20 24 32 40 48 56 64 80 96 112 128 144 160 192 256 320 384 512 640 768 1024}; #number of access
my @ARRAY_MEM_TEMP_Y = qw{1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25}; #number of repeats
my @ARRAY_MEM2_TEMP_X = qw{1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25}; #qw{4 8 12 16 20 24 32 40 48 56 64 80 96 112 128 144 160 192 256 320 384 512 640 768 1024};
my @ARRAY_MEM2_TEMP_Y = qw{1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25};
my @ARRAY_BRANCH_RAND = qw{0.04 0.08 0.12 0.16 0.2 0.24 0.28 0.32 0.36 0.40 0.44 0.48 0.52 0.56 0.6 0.64 0.68 0.72 0.76 0.80 0.84 0.88 0.92 0.96 1.0};

#Index for Parameter Arrays
my $Index_ADD = int(rand($knob_range));
my $Index_MUL = int(rand($knob_range));
my $Index_FADDS = int(rand($knob_range));
my $Index_FMULS = int(rand($knob_range));
my $Index_FADDD = int(rand($knob_range));
my $Index_FMULD = int(rand($knob_range));
my $Index_REG_DIST = int(rand($knob_range));
my $Index_ILP_DIST = int(rand($knob_range));
my $Index_BEQ = int(rand($knob_range));
my $Index_BNE = int(rand($knob_range));
my $Index_FLD = int(rand($knob_range));
my $Index_FLW = int(rand($knob_range));
my $Index_LB = int(rand($knob_range));
my $Index_LD = int(rand($knob_range));
my $Index_LW = int(rand($knob_range));
my $Index_FSD = int(rand($knob_range));
my $Index_FSW = int(rand($knob_range));
my $Index_SB = int(rand($knob_range));
my $Index_SD = int(rand($knob_range));
my $Index_SW = int(rand($knob_range));
my $Index_MEM_SIZE = int(rand($knob_range));
my $Index_MEM_STRIDE = int(rand($knob_range));
my $Index_MEM2_SIZE = int(rand($knob_range));
my $Index_MEM2_STRIDE = int(rand($knob_range));
my $Index_MEM_RATIO = int(rand($knob_range));
my $Index_MEM_TEMP_X = int(rand($knob_range));
my $Index_MEM_TEMP_Y = int(rand($knob_range));
my $Index_MEM2_TEMP_X = int(rand($knob_range));
my $Index_MEM2_TEMP_Y = int(rand($knob_range));
my $Index_BRANCH_RAND = int(rand($knob_range));

#Step 0: active uprobe
print "R-E-L-A-X\n";
#system(". /research/sgokul/MicroProbe_July2020/microprobe/venv/bin/activate");



#Step 1: nun simpoint of workload of interest (need to do this each time, since we are getting workload dependent stats, assuming that the prescribed uarch can change)
# run_wkld();


#Step2: Collect stats of interest and store them in some global variable. Current stats are: IPC, L1 miss rate, L2 miss rate, Mispred
# wkld_collect_stats();

#Step 2.5 - for all the direct knobs 'uarch indep', set those values first
# ansatz();

#Step3: Run grad (or others) to create the synthetic workload to reduce loss function 
# grad();
# greedy();


#Step4: Print final results
conclusion();

# system("exit");

system("ls");
exit;

###### end of 'main'



#Below are all the subs
sub run_wkld{

	print "Readyyyyyyyyyy UP!\n";

	system("rm -rf $rundir_wkld");

	#TODO: this is a bit shady at the moment since isa is different
    #	system("/research/sgokul/gem5-stable/gem5-stable//build/ARM/gem5.opt -d $rundir_wkld /research/sgokul/gem5-stable/gem5-stable//configs/example/se.py --cpu-type=DerivO3CPU --caches --l2cache --cpu-clock=2GHz --sys-clock=2GHz --cmd=$runfile_wkld --l1d_size=32kB  --l1i_size=32kB --l2_size=1MB --mem-size=1GB --maxinsts=100000000 ");#Gem5 execut command which calls arm_detailed_flex - for now running gcc
	#system("/research/sgokul/gem5-stable/gem5-stable//build/ARM/gem5.opt -d $rundir_wkld /research/sgokul/gem5-stable/gem5-stable//configs/example/se.py --cpu-type=DerivO3CPU --restore-simpoint-checkpoint -r 1 --checkpoint-dir /research/sgokul/simpoints_std/*.gcc/checkpoint --caches --l2cache --mem-size=2GB --cpu-clock=2GHz --sys-clock=2GHz --cmd=*.gcc --options=\"input.program 10\" --l1d_size=32kB  --l1i_size=32kB --l2_size=1MB --maxinsts=$wkld_maxinsts > dump_wkld ");#Gem5 execut command which calls arm_detailed_flex - for now running gcc
	system("/research/sgokul/gem5-stable/gem5-stable//build/ARM/gem5.opt -d $rundir_wkld /research/sgokul/gem5-stable/gem5-stable//configs/example/se.py --cpu-type=DerivO3CPU --restore-simpoint-checkpoint -r 1 --checkpoint-dir /research/sgokul/simpoints_std/*.gcc/checkpoint --caches --l2cache --mem-size=2GB --cpu-clock=2GHz --sys-clock=2GHz --cmd=gcc --l1d_size=32kB  --l1i_size=32kB --l2_size=1MB --maxinsts=$wkld_maxinsts > dump_wkld ");#Gem5 execut command which calls arm_detailed_flex - for now running gcc

	print "Watch this!!\n";


}#run_wkld

sub wkld_collect_stats{

	if (-e $output_file_wkld) {
		print "File exists!\n";
		if(-s $output_file_wkld > 1024){
			print "File has reasonable size!\n";
			
			#Bunch of stats - these are more stats than necessary - but surely we will incorporate more of these soon
			my $lunch_val1 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 commit.op_class_0::IntAlu  | awk '{print \$2}'`;
			my $lunch_val2 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 commit.op_class_0::IntMult | awk '{print \$2}'`;
			my $lunch_val3 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 commit.op_class_0::FloatAdd | awk '{print \$2}'`;
			my $lunch_val4 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 commit.op_class_0::FloatMult | awk '{print \$2}'`;
			my $lunch_val5 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 commit.op_class_0::MemRead | awk '{print \$2}'`;
			my $lunch_val6 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 commit.op_class_0::MemWrite | awk '{print \$2}'`;
			my $lunch_val7 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 commit.op_class_0::FloatMemRead | awk '{print \$2}'`;
			my $lunch_val8 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 commit.op_class_0::FloatMemWrite | awk '{print \$2}'`;
			my $lunch_val9 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 commit.branches | awk '{print \$2}'`;
			my $lunch_val10 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 commit.branchMispredicts | awk '{print \$2}'`;
			#my $lunch_val11 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 dcache.overall_misses::total | awk '{print \$2}'`;
			#my $lunch_val12 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 icache.overall_misses::total | awk '{print \$2}'`;
			#my $lunch_val13 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 l2.overall_misses::total | awk '{print \$2}'`;
			my $lunch_val11 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 dcache.overall_miss_rate::total | awk '{print \$2}'`;
			my $lunch_val12 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 icache.overall_miss_rate::total | awk '{print \$2}'`;
			my $lunch_val13 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 l2.overall_miss_rate::total | awk '{print \$2}'`;
			my $lunch_val14 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 iq.rate | awk '{print \$2}'`;
			my $lunch_val15 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 ipc_total | awk '{print \$2}'`;
			#TODO TEST - new additions
			my $lunch_val16 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 sim_ops | awk '{print \$2}'`; #total ops
		
		
			my $temp;	
			$temp = chomp($lunch_val1);
			$temp = chomp($lunch_val2);
			$temp = chomp($lunch_val3);
			$temp = chomp($lunch_val4);
			$temp = chomp($lunch_val5);
			$temp = chomp($lunch_val6);
			$temp = chomp($lunch_val7);
			$temp = chomp($lunch_val8);
			$temp = chomp($lunch_val9);
			$temp = chomp($lunch_val10);
			$temp = chomp($lunch_val11);
			$temp = chomp($lunch_val12);
			$temp = chomp($lunch_val13);
			$temp = chomp($lunch_val14);
			$temp = chomp($lunch_val15);
			$temp = chomp($lunch_val16);
			#In all correcting for ops
			$wkld_array[0] = ($lunch_val1 - $lunch_val9)/$lunch_val16; #TODO TEST removing branches from intalu
			$wkld_array[1] = $lunch_val2/$lunch_val16;
			$wkld_array[2] = $lunch_val3/$lunch_val16;
			$wkld_array[3] = $lunch_val4/$lunch_val16;
			$wkld_array[4] = $lunch_val5/$lunch_val16;
			$wkld_array[5] = $lunch_val6/$lunch_val16;
			$wkld_array[6] = $lunch_val7/$lunch_val16;
			$wkld_array[7] = $lunch_val8/$lunch_val16;
			$wkld_array[8] = $lunch_val9/$lunch_val16;
			$wkld_array[9] = ($lunch_val9 - $lunch_val10)/$lunch_val16; #TODO TEST Mispredicts -> Correct Prediction / Ops
			$wkld_array[10] = 1.0 - $lunch_val11; #TODO TEST DCache Misses -> HR 
			$wkld_array[11] = 1.0 - $lunch_val12; #TODO TEST ICache Misses -> HR
			$wkld_array[12] = 1.0 - $lunch_val13; #TODO TEST L2 Misses -> HR
			$wkld_array[13] = $lunch_val14;
			$wkld_array[14] = $lunch_val15;

			$wkld_array[6]=0; #TODO hack
			$wkld_array[7]=0; #TODO hack
		
			print "Wkld: Stats: IntAlu: $wkld_array[0] ,IntMult: $wkld_array[1] ,FloatAdd: $wkld_array[2] ,FloatMult: $wkld_array[3] ,MemRead: $wkld_array[4] ,MemWrite: $wkld_array[5] ,FloatMemRead: $wkld_array[6] ,FloatMemWrite: $wkld_array[7] ,branches: $wkld_array[8] ,!Mispredicts: $wkld_array[9] ,!dcache: $wkld_array[10] ,!icache: $wkld_array[11], !l2:$wkld_array[12] ,iq: $wkld_array[13], ipc: $wkld_array[14]\n";

			my $inst_val = `tac /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt | grep -m 1 sim_inst | awk '{print \$2}'`;#TODO
			print "Wkld: Inst is $inst_val\n";
		
			#TODO Maybe later think about adding power here	
            #			chdir($location4);
            #			system("/research/sgokul/gem5-mcpat/gem5-mcpat-parser/compute /research/sgokul/MicroProbe/m20out_gcc_test_wkld/stats.txt /research/sgokul/MicroProbe/m20out_gcc_test_wkld/config.ini /research/sgokul/gem5-mcpat/gem5-mcpat-parser/template.xml /research/sgokul/MicroProbe/configuration_uprobe.xml gem5-mcpat-parser /research/sgokul/McPAT_1.2/McPAT/mcpat 5");
            #			chdir($location3);
            #			$power_val = `/research/sgokul/McPAT_1.2/McPAT/mcpat -infile /research/sgokul/MicroProbe/configuration_uprobe.xml  -print_level 5 | grep -m 1 "Runtime Dynamic" `;
            #			print "$power_val";
		}
		else{ print "File has almost zero size!\n";}
	}
	else{ print "File does not exist!\n";}


    #Normalize all values
    #TODO - Normalizing to wkld values - these are just becoming 1
    for(my $n=0; $n<$knob_num; $n++){
        #$wkld_array_norm[$n]= ($wkld_array[$n] - $wkld_array_min[$n])/($wkld_array_max[$n] - $wkld_array_min[$n]); #old - normalizing to a higher power
        #$wkld_array_norm[$n]= ($wkld_array[$n] - $wkld_array_min[$n])/($wkld_array_max[$n] - $wkld_array_min[$n]);

        $wkld_array_max[$n] = $wkld_array[$n];#New
        $wkld_array_min[$n] = 0;
        $wkld_array_norm[$n]= 1;
    }

    print "Wkld: Norm Truth Stats: IntAlu: $wkld_array_norm[0] ,IntMult: $wkld_array_norm[1] ,FloatAdd: $wkld_array_norm[2] ,FloatMult: $wkld_array_norm[3] ,MemRead: $wkld_array_norm[4] ,MemWrite: $wkld_array_norm[5] ,FloatMemRead: $wkld_array_norm[6] ,FloatMemWrite: $wkld_array_norm[7] ,branches: $wkld_array_norm[8] ,Mispredicts: $wkld_array_norm[9] ,dcache: $wkld_array_norm[10] ,icache: $wkld_array_norm[11], l2:$wkld_array_norm[12] ,iq: $wkld_array_norm[13], ipc: $wkld_array_norm[14]\n";


    #Step c: Select values of interest
    $wkld_index_interest[9]=1; #Mispred
    $wkld_index_interest[10]=1; #DCmiss
    $wkld_index_interest[11]=1; #ICmiss
    $wkld_index_interest[12]=1; #L2miss
    $wkld_index_interest[14]=1; #IPC

    #Step d: Selects value for ansatz - not clear if these calues are actually lookedup
    $wkld_index_interest[0]=2; #IntAlu
    $wkld_index_interest[1]=2; #IntMult
    $wkld_index_interest[2]=2; #FloatAdd
    $wkld_index_interest[3]=2; #FloatMult
    $wkld_index_interest[4]=2; #MemRead
    $wkld_index_interest[5]=2; #MemWrite
    $wkld_index_interest[6]=2; #FloatMemRead
    $wkld_index_interest[7]=2; #FloatMemWrite
    $wkld_index_interest[8]=2; #Branches
    $wkld_index_interest[20]=2; #TODO Fake ansatz for memory size (1)


}#wkld_collect_stats

sub ansatz {

    #Knob indices
    #	$ADD = $[0];
    #	$MUL = $[1];
    #	$FADDS = $[2];
    #	$FMULS = $[3];
    #	$FADDD = $[4];
    #	$FMULD = $[5];
    #	$REG_DIST =$[6];
    #	$ILP_DIST =$[7];
    #	$BEQ = $[8];
    #	$BNE = $[9];
    #	$FLD = $[10];
    #	$FLW = $[11];
    #	$LB = $[12];
    #	$LD = $[13];
    #	$LW = $[14];
    #	$FSD = $[15];
    #	$FSW = $[16];
    #	$SB = $[17];
    #	$SD = $[18];
    #	$SW = $[19];
    #	$MEM_SIZE = $[20];
    #	$MEM_STRIDE =$[21];
    #	$MEM2_SIZE = $[22];
    #	$MEM2_STRIDE =$[23];
    #	$MEM_RATIO =$[24];
    #	25-28 TEMPORAL


    #for(my $n=0; $n<$knob_num; $n++){
    #	if($wkld_index_interest[$n]==2){ #This variable can be directly incorporated as fixed value of knob
    #		$knob_array_actual[$n] =  10.0 * $wkld_array[$n] / $wkld_maxinsts;
    #		$knob_array[$n] = int($knob_array_actual[$n]+0.5);
    #		$knob_ansatz[$n]=1;
    #
    #	}	
    #
    #}

    #Do variable by variable assignment since they are not aligned
    #$wkld_index_interest[0]=2; #IntAlu
    #	$ADD = $[0];
    $knob_array_actual[0] =  ($knob_range - 1) * $wkld_array[0];# / $wkld_maxinsts; TODO - raioed earlier
    $knob_array[0] = int($knob_array_actual[0]+0.5);
    $knob_ansatz[0]=1;

    #$wkld_index_interest[1]=2; #IntMult
    #	$MUL = $[1];
    $knob_array_actual[1] =  ($knob_range - 1) * $wkld_array[1];# / $wkld_maxinsts; TODO - raioed earlier
    $knob_array[1] = int($knob_array_actual[1]+0.5);
    $knob_ansatz[1]=1;

    #$wkld_index_interest[2]=2; #FloatAdd
    #	$FADDS = $[2];
    #	$FADDD = $[4];
    $knob_array_actual[2] =  ($knob_range - 1) * $wkld_array[2];# / $wkld_maxinsts; TODO - raioed earlier
    $knob_array[2] = int($knob_array_actual[2]+0.5);
    $knob_ansatz[2]=1;
    $knob_array_actual[4] =  0;
    $knob_array[4] = 0;
    $knob_ansatz[4]=1;

    #$wkld_index_interest[3]=2; #FloatMult
    #	$FMULS = $[3];
    #	$FMULD = $[5];
    $knob_array_actual[3] =  ($knob_range - 1) * $wkld_array[3];# / $wkld_maxinsts; TODO - raioed earlier
    $knob_array[3] = int($knob_array_actual[3]+0.5);
    $knob_ansatz[3]=1;
    $knob_array_actual[5] =  0;
    $knob_array[5] = 0;
    $knob_ansatz[5]=1;

    #$wkld_index_interest[4]=2; #MemRead
    #	$LB = $[12];
    #	$LD = $[13];
    #	$LW = $[14];
    $knob_array_actual[14] =  ($knob_range - 1) * $wkld_array[4];# / $wkld_maxinsts; TODO - raioed earlier
    $knob_array[14] = int($knob_array_actual[14]+0.5);
    $knob_ansatz[14]=1;
    $knob_array_actual[12] =  0;
    $knob_array[12] = 0;
    $knob_ansatz[12]=1;
    $knob_array_actual[13] =  0;
    $knob_array[13] = 0;
    $knob_ansatz[13]=1;

    #$wkld_index_interest[5]=2; #MemWrite
    #	$SB = $[17];
    #	$SD = $[18];
    #	$SW = $[19];
    $knob_array_actual[19] =  ($knob_range - 1) * $wkld_array[5];# / $wkld_maxinsts; TODO - raioed earlier
    $knob_array[19] = int($knob_array_actual[19]+0.5);
    $knob_ansatz[19]=1;
    $knob_array_actual[17] =  0;
    $knob_array[17] = 0;
    $knob_ansatz[17]=1;
    $knob_array_actual[18] =  0;
    $knob_array[18] = 0;
    $knob_ansatz[18]=1;

    #$wkld_index_interest[6]=2; #FloatMemRead
    #	$FLD = $[10];
    #	$FLW = $[11];
    $knob_array_actual[11] =  ($knob_range - 1) * $wkld_array[6];# / $wkld_maxinsts; TODO - raioed earlier
    $knob_array[11] = int($knob_array_actual[11]+0.5);
    $knob_ansatz[11]=1;
    $knob_array_actual[10] =  0;
    $knob_array[10] = 0;
    $knob_ansatz[10]=1;

    #$wkld_index_interest[7]=2; #FloatMemWrite
    #	$FSD = $[15];
    #	$FSW = $[16];
    $knob_array_actual[16] =  ($knob_range - 1) * $wkld_array[7];# / $wkld_maxinsts; TODO - raioed earlier
    $knob_array[16] = int($knob_array_actual[16]+0.5);
    $knob_ansatz[16]=1;
    $knob_array_actual[15] =  0;
    $knob_array[15] = 0;
    $knob_ansatz[15]=1;

    #$wkld_index_interest[8]=2; #Branches
    #	$BEQ = $[8];
    #	$BNE = $[9];
    $knob_array_actual[8] =  ($knob_range - 1) * $wkld_array[8];# / $wkld_maxinsts; TODO - raioed earlier
    $knob_array[8] = int($knob_array_actual[8]+0.5);
    $knob_ansatz[8]=1;
    $knob_array_actual[9] =  0;
    $knob_array[9] = 0;
    $knob_ansatz[9]=1;

    #Fake for memsize 1 TODO
    $knob_array_actual[20]=0;
    $knob_array[20]=0;
    $knob_ansatz[20]=1;

} #ansatz



sub loss_function{

    my ($ref_predicted_array) = @_;
    my @predicted_array = @{$ref_predicted_array};
    my @predicted_array_norm;

    #Normalize all values
    for(my $n=0; $n<$knob_num; $n++){
        if($wkld_array_max[$n]==0 || $predicted_array[$n]==0){
            $predicted_array_norm[$n]=1;#This is very rare if all variables are in use - if it does happen, its better to ignore those vars - using 1 here because of log
        }
        else{	
            $predicted_array_norm[$n]= ($predicted_array[$n] - $wkld_array_min[$n])/($wkld_array_max[$n] - $wkld_array_min[$n]);#new - based on how we updated the wkld normalizaiton, all this is doing is normalizing to workld
        }
    }

    print "Syn: Norm Predicted Stats: mean: $predicted_array_norm[0] , 95th: $predicted_array_norm[1] , 99th: $predicted_array_norm[2].\n";

    #Step a: Caclulate MSE using log (for now) 
    my $sum = 0;
    my $count = 0;
    print "Calculating Loss (using log): ";
    for(my $n=0; $n<$knob_num ; $n++){
        if($wkld_index_interest[$n]==1){
            my $log_val = log($predicted_array_norm[$n]);
            print "($predicted_array_norm[$n] , $wkld_array_norm[$n]), log is $log_val";
            #$sum = $sum + ($predicted_array_norm[$n] - $wkld_array_norm[$n])**2;
            $sum = $sum + abs($log_val);
            $count++;
        }
    }

    my $mean = $sum/$count;

    print "\nLoss - MSE: $mean\n";

    return $mean;

}#loss_function


sub conclusion {
    print "testing run finished.\n";
}#conclusion


sub greedy {

}#greedy


sub grad {
    #GOKUL-3: grad

    # 0) Parameters
    my $var_size = $knob_num;
    my $stop = 0;
    my $grad_itn = 0;
    my $max_itn = 200;#TODO 50
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
        print "GOKUL: Old METRIC is $metric_old\n";
        print "GOKUL: Old Loss is $loss_old\n";
        print "GOKUL: Value of knobs :";
        for(my $n=0; $n < $knob_num ; $n = $n + 1){
            print $knob_array_actual[$n];
            print ","
        }
        print "....\n";

        my @metric_array = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        my @step_array = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        my @grad_array = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        my @grad_array_norm = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        my $grad_max_index = 0;

        #c) perturb each knob and calculate metric at each and the gradients
        for(my $i = 0; $i < $var_size; $i=$i+1){
            if(!$knob_ansatz[$i]){ #This is not an ansatz

                #stochasticity
                my $do = 1;
                my $threshold = 50/(1+$grad_itn); #TODO give legit value if you want stochasticity - can make this dependent on itn (sim annealing?)
                my $randesh = int(rand(100));
                if($randesh < $threshold){
                    $do = 0;
                }
                if($do==1){
                    
                    #Step value for this itn (adaptive)
                    my $step_curry = (5-int($grad_itn/10));	
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

                #This if for only up
                #	if($knob_array[$i] < $knob_range - 1) {
                #		$knob_array[$i] = $knob_array[$i]  + 1;
                #		$step_array[$i]=1;
                #	}
                #	else {
                #		$knob_array[$i] = $knob_array[$i]  - 1;
                #		$step_array[$i]=-1;
                #	}
                #
                #	$overall_itn = $overall_itn + 1;
                #	$metric_array[$i] = work(\@knob_array,$overall_itn);
                #	$knob_array[$i] = $knob_array[$i] - $step_array[$i]; # Putting it back as before

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
                #if($grad_array[$i] > 0){
                if($grad_array[$grad_max_index] > 0){
                    $grad_array_norm[$i] = 1.0*$grad_array[$i]/abs($grad_array[$grad_max_index]); #TODO This is all gonna be fractional. Step size is 1
                }
                else {
                    $grad_array_norm[$i] = $grad_array[$i]; #In this case, all must be 0
                }
                #}
                #else{
                #	$grad_array_norm[$i]=0;
                #}
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
        #$knob_array[$grad_max_index] = $knob_array[$grad_max_index]+$step_array[$grad_max_index];
        for(my $i = 0; $i < $var_size; $i=$i+1){
            if(!$knob_ansatz[$i]){ #This is not an ansatz
                my $quant_val =  100.0*($knob_array_actual[$i] - int($knob_array_actual[$i]));
                my $rand = int(rand(100));
                if($rand < $quant_val){
                    $knob_array[$i] = int($knob_array_actual[$i]) + 1;
                    if($knob_array[$i] > $knob_range - 1) {
                        $knob_array[$i] = $knob_range - 1;
                    }
                }
                else{
                    $knob_array[$i] = int($knob_array_actual[$i]);
                }
                
                #$knob_array[$i] = int($knob_array_actual[$i] + 0.5); #TODO use this instead of above if you want gradual instead of lottery

                $knob_array_actual[$i] = $knob_array[$i]; #TODO - what this does is it makes changes per iteration more smooth - this is a bit convoluted way of doing things but at least it remains plug and play

            }#ansatz
        }


        # f) repeat, but stop at some point
        # set by max_itn, max iteration
        $grad_itn = $grad_itn+1;
        if($grad_itn >= $max_itn){
                $stop=1;
        }

    }
} # grad


sub work  { 
    #$side = $_[0]; 

	my $val = -1;
	my $power_val;
	my $inst_val;
	my ($ref_input_array, $itn) = @_;
	my @ubench_array = (-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);

	$itn = $itn + $start;
	my @input_array = @{$ref_input_array};
	print "\nValue of itn is:";
	print $itn;
	print "\nValue of vals is:";
	for(my $n=0; $n < $knob_num ; $n = $n + 1){
		print $input_array[$n];
		print ","
	}
	print "....";
	$Index_ADD = $input_array[0];
	$Index_MUL = $input_array[1];
	$Index_FADDS = $input_array[2];
	$Index_FMULS = $input_array[3];
	$Index_FADDD = $input_array[4];
	$Index_FMULD = $input_array[5];
	$Index_REG_DIST =$input_array[6];
	$Index_ILP_DIST =$input_array[7];
	$Index_BEQ = $input_array[8];
	$Index_BNE = $input_array[9];
	$Index_FLD = $input_array[10];
	$Index_FLW = $input_array[11];
	$Index_LB = $input_array[12];
	$Index_LD = $input_array[13];
	$Index_LW = $input_array[14];
	$Index_FSD = $input_array[15];
	$Index_FSW = $input_array[16];
	$Index_SB = $input_array[17];
	$Index_SD = $input_array[18];
	$Index_SW = $input_array[19];
	$Index_MEM_SIZE = $input_array[20];
	$Index_MEM_STRIDE =$input_array[21];
	$Index_MEM2_SIZE = $input_array[22];
	$Index_MEM2_STRIDE =$input_array[23];
	$Index_MEM_RATIO =$input_array[24];
	$Index_MEM_TEMP_X = $input_array[25];
	$Index_MEM_TEMP_Y =$input_array[26];
	$Index_MEM2_TEMP_X = $input_array[27];
	$Index_MEM2_TEMP_Y =$input_array[28];
	$Index_BRANCH_RAND =$input_array[29];



	$GOK_ADD = $ARRAY_ADD[$Index_ADD];      
	$GOK_MUL = $ARRAY_MUL[$Index_MUL];
	$GOK_FADDS = $ARRAY_FADDS[$Index_FADDS];
	$GOK_FMULS = $ARRAY_FMULS[$Index_FMULS];
	$GOK_FADDD = $ARRAY_FADDD[$Index_FADDD];
	$GOK_FMULD = $ARRAY_FMULD[$Index_FMULD];
	$GOK_REG_DIST = $ARRAY_REG_DIST[$Index_REG_DIST];
	$GOK_ILP_DIST = $ARRAY_ILP_DIST[$Index_ILP_DIST];
	$GOK_BEQ = $ARRAY_BEQ[$Index_BEQ];
	$GOK_BNE = $ARRAY_BNE[$Index_BNE];
	$GOK_FLD = $ARRAY_FLD[$Index_FLD];
	$GOK_FLW = $ARRAY_FLW[$Index_FLW];
	$GOK_LB = $ARRAY_LB[$Index_LB];
	$GOK_LD = $ARRAY_LD[$Index_LD];
	$GOK_LW = $ARRAY_LW[$Index_LW];
	$GOK_FSD = $ARRAY_FSD[$Index_FSD];
	$GOK_FSW = $ARRAY_FSW[$Index_FSW];
	$GOK_SB = $ARRAY_SB[$Index_SB];
	$GOK_SD = $ARRAY_SD[$Index_SD];
	$GOK_SW = $ARRAY_SW[$Index_SW];
	$GOK_MEM_SIZE = 8*1024; #TODO - Keepin this fixed at 8KB
#	$GOK_MEM_SIZE = $ARRAY_MEM_SIZE[$Index_MEM_SIZE];
	$GOK_MEM_STRIDE = $ARRAY_MEM_STRIDE[$Index_MEM_STRIDE];
	$GOK_MEM2_SIZE = $ARRAY_MEM2_SIZE[$Index_MEM2_SIZE];
	$GOK_MEM2_STRIDE = $ARRAY_MEM2_STRIDE[$Index_MEM2_STRIDE];
	$GOK_MEM_RATIO = $ARRAY_MEM_RATIO[$Index_MEM_RATIO];
	$GOK_MEM_TEMP_X = $ARRAY_MEM_TEMP_X[$Index_MEM_TEMP_X];
	$GOK_MEM_TEMP_Y = $ARRAY_MEM_TEMP_Y[$Index_MEM_TEMP_Y];
	$GOK_MEM2_TEMP_X = $ARRAY_MEM2_TEMP_X[$Index_MEM2_TEMP_X];
	$GOK_MEM2_TEMP_Y = $ARRAY_MEM2_TEMP_Y[$Index_MEM2_TEMP_Y];
	$GOK_BRANCH_RAND = $ARRAY_BRANCH_RAND[$Index_BRANCH_RAND];


	#SPECIALS
	#GOK_MEM_RATIO
	my $actual_ratio_mem1;
	my $actual_ratio_mem2;
	$actual_ratio_mem2 = $GOK_MEM_RATIO;
	$actual_ratio_mem1 = 100 - $GOK_MEM_RATIO; 
	#if($GOK_MEM_RATIO>0){
	#	$actual_ratio_mem1=1;
	#	$actual_ratio_mem2=$GOK_MEM_RATIO;
	#}
	#else{
	#	$actual_ratio_mem2=1;
	#	$actual_ratio_mem1=(-1)*$GOK_MEM_RATIO;
	#}
	

	print "Going to location 1...\n";
	chdir($location1);
	system("cp $template_name $file_name");

	system("sed -i 's/GOK_ADD/$GOK_ADD/g' $file_name");
	system("sed -i 's/GOK_MUL/$GOK_MUL/g' $file_name");
	system("sed -i 's/GOK_FADDS/$GOK_FADDS/g' $file_name");
	system("sed -i 's/GOK_FMULS/$GOK_FMULS/g' $file_name");
	system("sed -i 's/GOK_FADDD/$GOK_FADDD/g' $file_name");
	system("sed -i 's/GOK_FMULD/$GOK_FMULD/g' $file_name");
	system("sed -i 's/GOK_REG_DIST/$GOK_REG_DIST/g' $file_name");
	system("sed -i 's/GOK_ILP_DIST/$GOK_ILP_DIST/g' $file_name");
	system("sed -i 's/GOK_BEQ/$GOK_BEQ/g' $file_name");
	system("sed -i 's/GOK_BNE/$GOK_BNE/g' $file_name");
	system("sed -i 's/GOK_FLD/$GOK_FLD/g' $file_name");
	system("sed -i 's/GOK_FLW/$GOK_FLW/g' $file_name");
	system("sed -i 's/GOK_LB/$GOK_LB/g' $file_name");
	system("sed -i 's/GOK_LD/$GOK_LD/g' $file_name");
	system("sed -i 's/GOK_LW/$GOK_LW/g' $file_name");
	system("sed -i 's/GOK_FSD/$GOK_FSD/g' $file_name");
	system("sed -i 's/GOK_FSW/$GOK_FSW/g' $file_name");
	system("sed -i 's/GOK_SB/$GOK_SB/g' $file_name");
	system("sed -i 's/GOK_SD/$GOK_SD/g' $file_name");
	system("sed -i 's/GOK_SW/$GOK_SW/g' $file_name");
	system("sed -i 's/GOK_MEM_SIZE/$GOK_MEM_SIZE/g' $file_name");
	system("sed -i 's/GOK_MEM_STRIDE/$GOK_MEM_STRIDE/g' $file_name");
	system("sed -i 's/GOK_MEM_RATIO/$actual_ratio_mem1/g' $file_name");
	system("sed -i 's/GOK_MEM2_SIZE/$GOK_MEM2_SIZE/g' $file_name");
	system("sed -i 's/GOK_MEM2_STRIDE/$GOK_MEM2_STRIDE/g' $file_name");
	system("sed -i 's/GOK_MEM2_RATIO/$actual_ratio_mem2/g' $file_name");
	system("sed -i 's/GOK_SUFFIX/$itn/g' $file_name");
	system("sed -i 's/GOK_MEM_TEMP_X/$GOK_MEM_TEMP_X/g' $file_name");
	system("sed -i 's/GOK_MEM_TEMP_Y/$GOK_MEM_TEMP_Y/g' $file_name");
	system("sed -i 's/GOK_MEM2_TEMP_X/$GOK_MEM2_TEMP_X/g' $file_name");
	system("sed -i 's/GOK_MEM2_TEMP_Y/$GOK_MEM2_TEMP_Y/g' $file_name");
	system("sed -i 's/GOK_BRANCH_RAND/$GOK_BRANCH_RAND/g' $file_name");




	print "Generate the ubench...\n";
	system("python $file_name --output-dir=riscv_flex_gcc");
	print "Going to location 2...\n";
	chdir($location2);
	print "Compile benchmark";
	system("make clean -f $makefile");
	system("make -f $makefile");
	print "Going to location 3...\n";
	chdir($location3);
	my $actual_runfile = $runfile.$itn;
	print "Blue fifty eeeiiightt!\n";

	#TODO - We need to run with a config file etc which is not easy in new gem5. current using new gem5 naively

	#system("/research/sgokul/gem5-stable/gem5-stable//build/ARM/gem5.opt -d $rundir /research/sgokul/gem5-stable/gem5-stable//configs/example/se.py --cpu-type=arm_detailed --caches --l2cache --mem-size=2GB --cpu-clock=2GHz --sys-clock=2GHz --cmd=$runfile ");#Gem5 execut command which calls arm_detailed_flex
	system("rm -rf $rundir");
	system("/research/sgokul/gem5_2019/gem5//build/RISCV/gem5.opt -d $rundir /research/sgokul/gem5_2019/gem5/configs/example/se.py -c $actual_runfile --cpu-type=DerivO3CPU --caches --l2cache  --cpu-clock=2GHz --sys-clock=2GHz --l1d_size=32kB  --l1i_size=32kB --l2_size=1MB --mem-size=1GB --maxinsts=$ubench_maxinsts");

	print "Syn: Ready Ready!\n";
	if (-e $output_file) {
		print "Syn: File exists!\n";
		if(-s $output_file > 1024){

			print "Syn: File has reasonable size!\n";

			#Bunch of stats - these are more stats than necessary - but surely we will incorporate more of these soon
			my $lunch_val1 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.commit.op_class_0::IntAlu  | awk '{print \$2}'`;
			my $lunch_val2 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.commit.op_class_0::IntMult | awk '{print \$2}'`;
			my $lunch_val3 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.commit.op_class_0::FloatAdd | awk '{print \$2}'`;
			my $lunch_val4 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.commit.op_class_0::FloatMult | awk '{print \$2}'`;
			my $lunch_val5 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.commit.op_class_0::MemRead | awk '{print \$2}'`;
			my $lunch_val6 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.commit.op_class_0::MemWrite | awk '{print \$2}'`;
			my $lunch_val7 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.commit.op_class_0::FloatMemRead | awk '{print \$2}'`;
			my $lunch_val8 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.commit.op_class_0::FloatMemWrite | awk '{print \$2}'`;
			my $lunch_val9 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.commit.branches | awk '{print \$2}'`;
			my $lunch_val10 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.commit.branchMispredicts | awk '{print \$2}'`;
			#my $lunch_val11 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.dcache.overall_misses::total | awk '{print \$2}'`;
			#my $lunch_val12 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.icache.overall_misses::total | awk '{print \$2}'`;
			#my $lunch_val13 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.l2.overall_misses::total | awk '{print \$2}'`;
			my $lunch_val11 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.dcache.overall_miss_rate::total | awk '{print \$2}'`;
			my $lunch_val12 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.icache.overall_miss_rate::total | awk '{print \$2}'`;
			my $lunch_val13 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.l2.overall_miss_rate::total | awk '{print \$2}'`;
			my $lunch_val14 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 system.cpu.iq.rate | awk '{print \$2}'`;
			my $lunch_val15 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 ipc_total | awk '{print \$2}'`;
			#TODO TEST - new additions
			my $lunch_val16 = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 sim_ops | awk '{print \$2}'`;
		
			my $temp;	
			$temp = chomp($lunch_val1);
			$temp = chomp($lunch_val2);
			$temp = chomp($lunch_val3);
			$temp = chomp($lunch_val4);
			$temp = chomp($lunch_val5);
			$temp = chomp($lunch_val6);
			$temp = chomp($lunch_val7);
			$temp = chomp($lunch_val8);
			$temp = chomp($lunch_val9);
			$temp = chomp($lunch_val10);
			$temp = chomp($lunch_val11);
			$temp = chomp($lunch_val12);
			$temp = chomp($lunch_val13);
			$temp = chomp($lunch_val14);
			$temp = chomp($lunch_val15);
			$temp = chomp($lunch_val16);
			#In all correcting for ops
			$ubench_array[0] = ($lunch_val1 - $lunch_val9)/$lunch_val16; #TODO TEST removing branches from intalu
			$ubench_array[1] = $lunch_val2/$lunch_val16;
			$ubench_array[2] = $lunch_val3/$lunch_val16;
			$ubench_array[3] = $lunch_val4/$lunch_val16;
			$ubench_array[4] = $lunch_val5/$lunch_val16;
			$ubench_array[5] = $lunch_val6/$lunch_val16;
			$ubench_array[6] = $lunch_val7/$lunch_val16;
			$ubench_array[7] = $lunch_val8/$lunch_val16;
			$ubench_array[8] = $lunch_val9/$lunch_val16;
			$ubench_array[9] = ($lunch_val9 - $lunch_val10)/$lunch_val16; #TODO TEST Mispredicts -> Correct Prediction / Ops
			$ubench_array[10] = 1.0 - $lunch_val11; #TODO TEST DCache Misses -> HR 
			$ubench_array[11] = 1.0 - $lunch_val12; #TODO TEST ICache Misses -> HR
			$ubench_array[12] = 1.0 - $lunch_val13; #TODO TEST L2 Misses -> HR
			$ubench_array[13] = $lunch_val14;
			$ubench_array[14] = $lunch_val15;
			
			print "Syn: Stats: IntAlu: $ubench_array[0] ,IntMult: $ubench_array[1] ,FloatAdd: $ubench_array[2] ,FloatMult: $ubench_array[3] ,MemRead: $ubench_array[4] ,MemWrite: $ubench_array[5] ,FloatMemRead: $ubench_array[6] ,FloatMemWrite: $ubench_array[7] ,branches: $ubench_array[8] ,!Mispredicts: $ubench_array[9] ,!dcache: $ubench_array[10] ,!icache: $ubench_array[11], !l2:$ubench_array[12] ,iq: $ubench_array[13], ipc: $ubench_array[14] \n";

			$inst_val = `tac /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt | grep -m 1 sim_inst | awk '{print \$2}'`;#TODO
			print "Syn: Inst is $inst_val\n";
		
			#TODO Maybe later think about adding power here	
            #			chdir($location4);
            #			system("/research/sgokul/gem5-mcpat/gem5-mcpat-parser/compute /research/sgokul/MicroProbe/m20out_gcc_test_ubench/stats.txt /research/sgokul/MicroProbe/m20out_gcc_test_ubench/config.ini /research/sgokul/gem5-mcpat/gem5-mcpat-parser/template.xml /research/sgokul/MicroProbe/configuration_uprobe.xml gem5-mcpat-parser /research/sgokul/McPAT_1.2/McPAT/mcpat 5");
            #			chdir($location3);
            #			$power_val = `/research/sgokul/McPAT_1.2/McPAT/mcpat -infile /research/sgokul/MicroProbe/configuration_uprobe.xml  -print_level 5 | grep -m 1 "Runtime Dynamic" `;
            #			print "$power_val";
		}
		else{ print "Syn: File has almost zero size!\n";}
	}
	else{ print "Syn: File does not exist!\n";}
			
	print "Syn: Done Done-a Done!\n";

	$val = (1.0/loss_function(\@ubench_array));

	return $val; #TODO returned value is maximized. So to minimize loss, we should max 1/loss. so val is 1/loss
} #work 


__END__


