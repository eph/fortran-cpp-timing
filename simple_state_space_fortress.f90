module model_t
  use, intrinsic :: iso_fortran_env, only: wp => real64

  use fortress_bayesian_model_t, only: fortress_abstract_bayesian_model
  use fortress_prior_t, only: fortress_abstract_prior
  use fortress_random_t, only: fortress_random
  
  use, intrinsic ::  iso_c_binding, only: c_double, c_int, c_loc, c_ptr

  implicit none

  type, public, extends(fortress_abstract_bayesian_model) :: model
   contains
     procedure :: lik
     procedure :: dlik
  end type model


  interface model
     module procedure new_model
  end interface model
  

  type, public, extends(fortress_abstract_prior) :: SimplePrior
     real(wp) :: LB, UB

     contains
       procedure rvs
       procedure logpdf
       procedure dlogpdf

  end type SimplePrior

  interface SimplePrior
     module procedure new_prior
  end interface SimplePrior
  

  interface
     function gradient(y, x, g) bind(C, name="gradient_")
       use, intrinsic :: iso_c_binding
       type(c_ptr), value :: y
       real(c_double) :: x(*)
       real(c_double), intent(out) :: g(*)
       integer(c_int) :: gradient
     end function gradient    
  end interface


contains

  type(model) function new_model() result(self)

    character(len=144) :: name, datafile, priorfile
    integer :: nobs, T, ns, npara, neps
    
    name = 'ss'
    datafile = '/home/eherbst/Dropbox/code/fortress/test/test_data.txt'
    priorfile = '/home/eherbst/Dropbox/code/fortress/test/test_prior_model.txt'

    nobs = 1
    T = 80
     
    npara = 2
     
    allocate(self%prior, source=SimplePrior())
    call self%construct_model(name, datafile, npara, nobs, T)

  end function new_model

  real(wp) function lik(self, para, T) result(l)

    class(model), intent(inout) :: self
    real(wp), intent(in) :: para(self%npara)

    integer, intent(in), optional :: T

    real(c_double), target :: yy_copy(self%nobs, self%T)

    interface
       function loglikelihood(y,x) bind(C, name="loglikelihood_")
         use, intrinsic :: iso_c_binding
         type(c_ptr), value, intent(in) :: y
         real(c_double), intent(in) :: x(*)
         real(c_double) :: loglikelihood
       end function loglikelihood
    end interface
    
    l = -1000000000.0_wp
    if (para(1) < 0.0_wp) return
    if (para(2) < 0.0_wp) return
    if (para(1) > 1.0_wp) return
    if (para(2) > 1.0_wp) return

    yy_copy = self%yy
    l = loglikelihood(c_loc(yy_copy), para)
  end function lik


  function dlik(self, para, T) result(dl)

    class(model), intent(inout) :: self
    real(wp), intent(in) :: para(self%npara)

    integer, intent(in), optional :: T

    real(wp) :: dl(self%npara)

    integer :: r

    real(c_double), target :: yy_copy(self%nobs, self%T)

    dl = -1000000000.0_wp
    if (para(1) < 0.0_wp) return
    if (para(2) < 0.0_wp) return
    if (para(1) > 1.0_wp) return
    if (para(2) > 1.0_wp) return
    
    yy_copy = self%yy
    !r = gradient(c_loc(yy_copy), para,dl )

  end function dlik


  type(SimplePrior) function new_prior() result(pr)

    pr%npara = 2
    pr%LB = 0.0_wp
    pr%UB = 1.0_wp
  
  end function new_prior

  function rvs(self, nsim, seed, rng) result(parasim)

    class(SimplePrior), intent(inout) :: self
    integer, intent(in) :: nsim
    integer, optional :: seed

    type(fortress_random), optional, intent(inout) :: rng

    type(fortress_random) :: use_rng
    real(wp) :: parasim(self%npara, nsim), parasimT(nsim, self%npara)


    if (present(rng)) then
       use_rng = rng
    else
       use_rng = fortress_random()
    end if
    parasim = use_rng%uniform_rvs(self%npara, nsim, 0.0_wp, 1.0_wp) 


  end function rvs

  real(wp) function logpdf(self, para) result(lpdf)

    class(SimplePrior), intent(inout) :: self
    real(wp), intent(in) :: para(self%npara)

    lpdf = -1000000000.0_wp
    if (para(1) < self%LB) return
    if (para(2) < self%LB) return
    if (para(1) > self%UB) return
    if (para(2) > self%UB) return
  
    lpdf = 0.0_wp
    return

  end function logpdf

  function dlogpdf(self, para) result(dl)

    class(SimplePrior), intent(inout) :: self
    real(wp), intent(in) :: para(self%npara)
    real(wp) :: dl(self%npara)

    dl= -1000000000.0_wp
    if (para(1) < self%LB) return
    if (para(2) < self%LB) return
    if (para(1) > self%UB) return
    if (para(2) > self%UB) return
  
    dl = 0.0_wp
    return

  end function dlogpdf

end module model_t

