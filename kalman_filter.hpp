#include <iostream>
#include <stan/math.hpp>
 
using Eigen::Matrix;
using Eigen::Dynamic;
 
double kalman_filter(Matrix<double, Dynamic, Dynamic>& yy, std::vector<double>& para) {
 
  Matrix<double, Dynamic, Dynamic> TT(2,2);
  Matrix<double, Dynamic, Dynamic> RR(2,1);
  Matrix<double, Dynamic, Dynamic> QQ(1,1);
 
  Matrix<double, Dynamic, Dynamic> ZZ(1,2);
  Matrix<double, Dynamic, Dynamic> HH(1,1);
  Matrix<double, Dynamic, 1> DD(1);
 
 
  double thet1 = para[0];
  double thet2 = para[1];
 
  double phi1 = pow(thet1,2);
  double phi2 = 1.0 - pow(thet1,2);
  double phi3 = phi2 - thet1*thet2;
 
  //Matrix<double, Dynamic, Dynamic> yy(1,80);
  TT << phi1, 0,             
    phi3, phi2;
  RR << 1.0, 0.0;
  QQ << 1.0;
 
  DD << 0.0;
  ZZ << 1.0, 1.0;
  HH << 0.0;
 
 
  Matrix<double, Dynamic, 1> At(2);
  Matrix<double, Dynamic, Dynamic> Pt(2,2);
  At << 0,0;
 
  Pt <<  -1/(pow(phi1,2) - 1), 
    phi1*phi3/((pow(phi1,2) - 1)*(phi1*phi2 - 1)),
    phi1*phi3/((pow(phi1,2) - 1)*(phi1*phi2 - 1)),
    -pow(phi3,2)*(phi1*phi2 + 1)/((pow(phi1,2) - 1)*(pow(phi2,2) - 1)*(phi1*phi2 - 1));
 
  Matrix<double, Dynamic, 1> yi(1);
 
  Matrix<double, Dynamic, 1> err(1);
  Matrix<double, Dynamic, Dynamic> Ft(1,1);
  Matrix<double, Dynamic, Dynamic> invFt(1,1);
 
  Matrix<double, Dynamic, Dynamic> RQR(2,2);
  RQR = RR * QQ * RR.transpose();
 
 
 
  Matrix<double, Dynamic, Dynamic> Kt(2, 1);
 
 
  double lp = 0;
 
 
  for (int i = 0; i < yy.cols(); i++) {
    yi = yy.col(i);
 
    err = yi - DD - ZZ * At;
    auto PtZZp = Pt * ZZ.transpose();
    Ft = ZZ * PtZZp + HH;
 
    invFt = Ft.inverse();
 
    lp += 0.5 * stan::math::NEG_LOG_TWO_PI - 0.5 * (std::log(Ft.determinant()) + err.transpose() * invFt * err);
 
    Kt = TT * PtZZp;
 
    At = TT * At + Kt * invFt * err; 
 
    Pt = TT * Pt * TT.transpose() - Kt * invFt * Kt.transpose();
    Pt += RQR;
 
  }
 
  return lp;
}
