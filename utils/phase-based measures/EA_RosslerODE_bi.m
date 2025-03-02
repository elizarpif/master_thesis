function dD = EA_RosslerODE_bi(v,w,Ex,Ey)

% Pair of Rössler dynamics with coupling X->Y (Ex) and coupling Y->X (Ey)
% INPUTS:
%         - v: 3 dimension state of system X
%         - w: 3 dimension state of system Y
%         - Ex: coupling strength X -> Y
%         - Ey: coupling strength Y -> X
% OUTPUTS:
%         - dD: 6 dimension state of system X (dx) and system Y (dy)
%
% * This function needs to be called using an integrator, in this case
% "Integrator_DynamicNoise"*
%--------------------------------------------------------------------------

% i) Natural frequencies for system X (wx) and system Y (wy) used in the
% manuscript
wx=0.89;
wy=0.85;

% ii) Differential equations for system X
dx = [(-wx*v(2)-v(3))+Ey*(w(1)-v(1));
    wx*v(1)+0.165*v(2);
    (v(1)-10)*v(3)+0.2];

% iii) Differential equations for system Y

dy = [(-wy*w(2)-w(3))+Ex*(v(1)-w(1));
    wy*w(1)+0.165*w(2);
    (w(1)-10)*w(3)+0.2];

dD=[dx;dy];

end