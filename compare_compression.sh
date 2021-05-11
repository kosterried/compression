#!/bin/bash

# This script compares the different compression methods using COSMO output data.  
# Written 28/4/21 by Katie Osterried.

#SBATCH --job-name=compress_test
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --partition=prepost
#SBATCH --constraint=mc
#SBATCH --account=g110

#--------------------------------------------------------------------------------
# USER information section
# Users please fill in this section before running the script

# Path to the input file
input_file="test_file.nc"

# Path to the zstd executable
zstd_path="/scratch/snx3000/ksilver/compression/zstd/programs"

# Path to the sz executable
sz_path="/scratch/snx3000/ksilver/compression/install_sz/bin"

# Path to the zfp executable
zfp_path="/scratch/snx3000/ksilver/compression/zfp/build/bin"

# String containing number of data dimensions, followed by the dimensions themselves
dims="4 1 26 1180 2100" 

#--------------------------------------------------------------------------------
# Setup
TIMEFORMAT=%R
module load daint-gpu
module load NCO
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$zfp_path/../lib64
#--------------------------------------------------------------------------------
# gzip

echo "Starting gzip"

# Compress
gz_1_time_comp=`(time gzip -1 -k $input_file) 2>&1`
mv *.gz test_gz1.nc
gz_9_time_comp=`(time gzip -9 -k $input_file) 2>&1`
mv *.gz test_gz9.nc.gz
mv test_gz1.nc test_gz1.nc.gz

# Get compressed file size
gz_1_size=$(ls -lah test_gz1.nc.gz | awk -F " " {'print $5'})
gz_9_size=$(ls -lah test_gz9.nc.gz | awk -F " " {'print $5'})

# Decompress
gz_1_time_decomp=`(time gunzip test_gz1.nc.gz) 2>&1`
gz_9_time_decomp=`(time gunzip test_gz9.nc.gz) 2>&1`

# Output results to file
echo "gzip" > "compression.out"
echo "$gz_1_time_comp" >> "compression.out"
echo "$gz_9_time_comp" >> "compression.out"
echo "$gz_1_size" >> "compression.out"
echo "$gz_9_size" >> "compression.out"
echo "$gz_1_time_decomp" >> "compression.out"
echo "$gz_9_time_decomp" >> "compression.out"

echo "Finished with gzip"

#--------------------------------------------------------------------------------
# bzip2

echo "Starting bzip2"

# Compress
bz_1_time_comp=`(time bzip2 -1 -k $input_file) 2>&1`
mv *.bz2 test_bz1.nc
bz_9_time_comp=`(time bzip2 -9 -k $input_file) 2>&1`
mv *.bz2 test_bz9.nc.bz2
mv test_bz1.nc test_bz1.nc.bz2

# Get compressed file size
bz_1_size=$(ls -lah test_bz1.nc.bz2 | awk -F " " {'print $5'})
bz_9_size=$(ls -lah test_bz9.nc.bz2 | awk -F " " {'print $5'})

# Decompress
bz_1_time_decomp=`(time bzip2 -d test_bz1.nc.bz2) 2>&1`
bz_9_time_decomp=`(time bzip2 -d test_bz9.nc.bz2) 2>&1`

# Output results to file
echo "bzip2" >> "compression.out"
echo "$bz_1_time_comp" >> "compression.out"
echo "$bz_9_time_comp" >> "compression.out"
echo "$bz_1_size" >> "compression.out"
echo "$bz_9_size" >> "compression.out"
echo "$bz_1_time_decomp" >> "compression.out"
echo "$bz_9_time_decomp" >> "compression.out"

echo "Finished with bzip2"

#--------------------------------------------------------------------------------
# zstd

echo "Starting zstd"

# Compress
zstd_3_time_comp=`(time $zstd_path/zstd -q $input_file) 2>&1`
mv *.zst test_zstd3.nc
zstd_19_time_comp=`(time $zstd_path/zstd -q -19 $input_file) 2>&1`
mv *.zst test_zstd19.nc.zst
mv test_zstd3.nc test_zstd3.nc.zst

# Get compressed file size
zstd_3_size=$(ls -lah test_zstd3.nc.zst | awk -F " " {'print $5'})
zstd_19_size=$(ls -lah test_zstd19.nc.zst | awk -F " " {'print $5'})

# Decompress
zstd_3_time_decomp=`(time $zstd_path/zstd -q -d test_zstd3.nc.zst) 2>&1`
zstd_19_time_decomp=`(time $zstd_path/zstd -q -d test_zstd19.nc.zst) 2>&1`

# Output results to file
echo "zstd" >> "compression.out"
echo "$zstd_3_time_comp" >> "compression.out"
echo "$zstd_19_time_comp" >> "compression.out"
echo "$zstd_3_size" >> "compression.out"
echo "$zstd_19_size" >> "compression.out"
echo "$zstd_3_time_decomp" >> "compression.out"
echo "$zstd_19_time_decomp" >> "compression.out"

echo "Finished with zstd"

#--------------------------------------------------------------------------------
# bit grooming

echo "Starting bit grooming"

# Compress
bg_7_time_comp=`(time ncks -7 --ppc default=7 $input_file test_bg7.nc) 2>&1`
bg_4_time_comp=`(time ncks -7 --ppc default=4 $input_file test_bg4.nc) 2>&1`

# Get compressed file size
bg_7_size=$(ls -lah test_bg7.nc | awk -F " " {'print $5'})
bg_4_size=$(ls -lah test_bg4.nc | awk -F " " {'print $5'})

# Decompress
bg_7_time_decomp=`(time ncks -7 -L 0 test_bg7.nc test_bg7_decomp.nc) 2>&1`
bg_4_time_decomp=`(time ncks -7 -L 0 test_bg4.nc test_bg4_decomp.nc) 2>&1`

# Output results to file
echo "bit grooming" >> "compression.out"
echo "$bg_7_time_comp" >> "compression.out"
echo "$bg_4_time_comp" >> "compression.out"
echo "$bg_7_size" >> "compression.out"
echo "$bg_4_size" >> "compression.out"
echo "$bg_7_time_decomp" >> "compression.out"
echo "$bg_4_time_decomp" >> "compression.out"

echo "Finished with bit grooming"
#--------------------------------------------------------------------------------
# SZ

echo "Starting SZ"

# Compress
sz_7_time_comp=`(time $sz_path/sz -z -f -M ABS -A 1E-7 -i $input_file -$dims) 2>&1`
mv *.sz test_sz7.nc
sz_4_time_comp=`(time $sz_path/sz -z -f -M ABS -A 1E-4 -i $input_file -$dims) 2>&1`
mv *.sz test_sz4.nc.sz
mv test_sz7.nc test_sz7.nc.sz

# Get compressed file size
sz_7_size=$(ls -lah test_sz7.nc.sz | awk -F " " {'print $5'})
sz_4_size=$(ls -lah test_sz4.nc.sz | awk -F " " {'print $5'})

# Decompress
sz_7_time_decomp=`(time $sz_path/sz -x -f -s test_sz7.nc.sz -$dims) 2>&1`
sz_4_time_decomp=`(time $sz_path/sz -x -f -s test_sz4.nc.sz -$dims) 2>&1`

# Output results to file
echo "SZ" >> "compression.out"
echo "$sz_7_time_comp" >> "compression.out"
echo "$sz_4_time_comp" >> "compression.out"
echo "$sz_7_size" >> "compression.out"
echo "$sz_4_size" >> "compression.out"
echo "$sz_7_time_decomp" >> "compression.out"
echo "$sz_4_time_decomp" >> "compression.out"

echo "Finished with SZ"
#--------------------------------------------------------------------------------
# zfp

echo "Starting zfp"

# Compress
zfp_32_time_comp=`(time $zfp_path/zfp -q -i $input_file -o test_zfp32.nc -f -$dims -p 32) 2>&1`
zfp_16_time_comp=`(time $zfp_path/zfp -q -i $input_file -o test_zfp16.nc -f -$dims -p 16) 2>&1`

# Get compressed file size
zfp_32_size=$(ls -lah test_zfp32.nc | awk -F " " {'print $5'})
zfp_16_size=$(ls -lah test_zfp16.nc | awk -F " " {'print $5'})

# Decompress
zfp_32_time_decomp=`(time $zfp_path/zfp -q -z test_zfp32.nc -o test_zfp32_decomp.nc -f -$dims -p 32) 2>&1`
zfp_16_time_decomp=`(time $zfp_path/zfp -q -z test_zfp16.nc -o test_zfp16_decomp.nc -f -$dims -p 16) 2>&1`

# Output results to file
echo "zfp" >> "compression.out"
echo "$zfp_32_time_comp" >> "compression.out"
echo "$zfp_16_time_comp" >> "compression.out"
echo "$zfp_32_size" >> "compression.out"
echo "$zfp_16_size" >> "compression.out"
echo "$zfp_32_time_decomp" >> "compression.out"
echo "$zfp_16_time_decomp" >> "compression.out"

echo "Finished with zfp"

