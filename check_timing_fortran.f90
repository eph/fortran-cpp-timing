

program check_timing
  use iso_fortran_env, only: wp => real64


  use model_t, only: model


  implicit none

  type(model) :: smc_model

  real(wp) :: p0(2), lik0
  integer :: i

  real(wp) :: start_time, stop_time, s

  smc_model = model()
  

  p0 = [0.45_wp, 0.45_wp]
  print*, 'p0                  :', p0 
  print*, 'C++ likelihoood     :', smc_model%lik(p0)

  call cpu_time(start_time)
  do i = 1, 1000
     lik0 = smc_model%lik(p0)
  end do
  call cpu_time(stop_time)
  s = stop_time - start_time
  print*, '1000 C++ likelihood evaluations took', s*1000.0d0, 'milliseconds.'




end program check_timing

