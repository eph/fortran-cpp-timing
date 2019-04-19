CC=/msu/home/m1eph00/miniconda2/envs/proxy-svar/bin/x86_64-conda_cos6-linux-gnu-g++
FC=/msu/home/m1eph00/miniconda2/envs/proxy-svar/bin/x86_64-conda_cos6-linux-gnu-gfortran

STAN_DIR=~/Dropbox/code/math
CPP_HEADER_FILES=-I $(STAN_DIR) \
	-I $(STAN_DIR)/lib/eigen_3.3.3/ \
	-I $(STAN_DIR)/lib/boost_1.69.0/ \
	-I $(STAN_DIR)/lib/sundials_4.1.0/include





check_timing_fortran: kalman_filter.hpp kalman_filter_wrapper.cpp simple_state_space.f90 check_timing_fortran.f90
	$(CC) -O3 -I. $(CPP_HEADER_FILES) -std=c++14 -c kalman_filter_wrapper.cpp
	$(FC) -O3 kalman_filter_wrapper.o simple_state_space.f90  check_timing_fortran.f90 -I. -lstdc++  -o check_timing_fortran 

check_timing_cpp: kalman_filter.hpp check_timing_cpp
	$(CC) -O3 -I. $(CPP_HEADER_FILES) -std=c++14 check_timing_cpp.cpp -o check_timing_cpp
