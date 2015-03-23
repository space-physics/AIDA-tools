qwe(dr,fi,r1,r2) = sum(min((r1^2).^.5,((dr+r2*cos(fi)).^2+(r2*sin(fi)).^2).^.5).^2.*gradient(atan2(r2*sin(fi),(dr+r2*cos(fi)))))
