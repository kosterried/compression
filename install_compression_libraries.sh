#!/bin/bash

# This scripts downloads and installs the Zstandard compression library, the 
# SZ compression library including the HDF5-filter, and the zfp compression 
# library.  This script requires the user to have an SSH key for Github and is
# specific to Piz Daint.
#
# Written 11/5/21 by Katie Osterried.

#-----------------------------------------------------------------------------
# Download and install Zstandard compression library

echo "Downloading and installing Zstandard"
git clone git@github.com:facebook/zstd.git
cd zstd
git checkout v1.4.9
make install PREFIX=build
cd programs/build
echo "Zstandard installed in $(pwd)"
cd ../../..

echo "Finished with Zstandard"

#-----------------------------------------------------------------------------
# Download and install SZ compression library

echo "Downloading and installing SZ"
git clone git@github.com:szcompressor/SZ.git
cd SZ
git checkout v2.1.9
./configure --prefix=$(pwd)/build
make
make install

echo "SZ is installed in $(pwd)/build"
install_dir="$(pwd)/build"
install_dir_text="SZPATH   =$(install_dir)"
hdf5path="/opt/cray/pe/hdf5/1.12.0.0/GNU/8.2"
hdf5path_text="HDF5PATH    = /opt/cray/pe/hdf5/1.12.0.0/GNU/8.2"
echo "Finished installing SZ" 

echo "Installing HDF5 SZ filter"
cd hdf5-filter/H5Z-SZ
sed -i '/SZPATH/c\'"${install_dir_text}" Makefile
sed -i '/HDF5PATH/c\'"${hdf5path_text}" Makefile
make
make install

echo "HDF5 SZ filter installed in $(install_dir)"
echo "Before using the HDF5 SZ filter, set the following environmental variables:"
echo "export HDF5_PLUGIN_PATH=$(install_dir)/lib"
echo "export LD_LIBRARY_PATH=$(hdf5path)/lib:$(install_dir)/lib:\$LD_LIBRARY_PATH"
cd ../../..
echo "Finished installing HDF5 SZ filter"

#-----------------------------------------------------------------------------
# Download and install zfp compression library

echo "Downloading and installing zfp"
git clone git@github.com:LLNL/zfp.git
cd zfp
git checkout 0.5.5
mkdir build
cd build
cmake ..
cmake --build . --config Release

echo "zfp is installed in $(pwd)/bin"
echo "Before using the zfp library, set the following environmental variable:"
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$(pwd)/lib64"


