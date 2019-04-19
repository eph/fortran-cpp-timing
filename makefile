CONDA_DIR=/home/eherbst/anaconda3

CC=$(CONDA_DIR)/bin/x86_64-conda_cos6-linux-gnu-g++
FC=$(CONDA_DIR)/bin/x86_64-conda_cos6-linux-gnu-gfortran

STAN_DIR=~/Dropbox/code/math
CPP_HEADER_FILES=-I $(STAN_DIR) \
	-I $(STAN_DIR)/lib/eigen_3.3.3/ \
	-I $(STAN_DIR)/lib/boost_1.69.0/ \
	-I $(STAN_DIR)/lib/sundials_4.1.0/include



.PHONY: check_timing_fortran check_timing_fortran_fortress check_timing_cpp

check_timing_fortran: kalman_filter.hpp kalman_filter_wrapper.cpp simple_state_space.f90 check_timing_fortran.f90
	$(CC) -O3 -I. $(CPP_HEADER_FILES) -std=c++14 -c kalman_filter_wrapper.cpp
	$(FC) -O3 kalman_filter_wrapper.o simple_state_space.f90  check_timing_fortran.f90 -I. -lstdc++  -o check_timing_fortran 

check_timing_cpp: kalman_filter.hpp check_timing_cpp
	$(CC) -O3 -I. $(CPP_HEADER_FILES) -std=c++14 check_timing_cpp.cpp -o check_timing_cpp



LIB=$(CONDA_DIR)/lib/
INC=$(CONDA_DIR)/include/
FPP=fypp
FRUIT=-I$(INC)/fruit -L$(LIB) -lfruit -Wl,-rpath=$(LIB)
FLAP=-I$(INC)/flap -L$(LIB) -lflap
FORTRESS=-I$(INC)/fortress -L$(LIB)/fortress -lfortress
JSON=-I$(INC)/json-fortran -L$(LIB)/json-fortran -ljsonfortran

check_timing_fortran_fortress: kalman_filter.hpp simple_state_space_fortress.f90 check_timing_fortran.f90
	$(CC) -O3 -I. $(CPP_HEADER_FILES) -std=c++14 -c kalman_filter_wrapper.cpp
	$(FC) -O3 -Wl,--start-group $(FORTRESS) $(JSON) $(FLAP) $(FRUIT) -Wl,--end-group kalman_filter_wrapper.o simple_state_space_fortress.f90  check_timing_fortran.f90 -I. -lstdc++  -o check_timing_fortran_fortress -lopenblas

