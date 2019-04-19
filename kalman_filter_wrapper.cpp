#include <kalman_filter.hpp> 

double loglikelihood(double y[], double x[]);
 
extern"C" double loglikelihood_(double *y, double *x) {
  return loglikelihood(y,x);
}
 
double loglikelihood(double y[], double x[])
{
  std::vector<double> para(2);
  double lpdf;
  double l;
 
  Matrix<double, Dynamic, Dynamic> y_eigen = Eigen::Map<Matrix<double, 1, 80>>(y);
 
  para[0] = x[0];
  para[1] = x[1];
 
  lpdf = kalman_filter(y_eigen, para);
 
  return lpdf;
}
