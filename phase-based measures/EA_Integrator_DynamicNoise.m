function [x, times] = EA_Integrator_DynamicNoise(deriv,d,N,dt,inicond,Ex,Ey, sqrt_2Dx, sqrt_2Dy)
% Integration using Euler for pair dynamics where the noise is dimensions 1 and 2 (see
% equations from manuscript)
% INPUTS:
%        -  deriv: specifies the script of the derivative, e.g. @RosslerODE_bi
%        - d: dimension
%        - N: Number of datapoints
%        - dt: time step
%        - inicond: initial conditions vector of d elements
%        - sqrt_2Dx, sqrt_2Dy: standard deviation of noise for X and Y
%        - Ex: unidirectional coupling X->Y
%        - Ey: unidirectional coupling Y->X
%
% OUTPUTS:
%        - times: vector of time of equations
%        - x: obtained results
%
%--------------------------------------------------------------------------

% i) Setting of integration-time and -step. Setting initial conditions

d = length(inicond);
times = [0:dt:(N-1)*dt];
x = zeros(length(times),d);
x(1,:) = inicond;

% ii) Call of integrater. Iterative call of Euler steps

j = 1;
for steps=times(1:length(times)-1)
    j = j +1;
    % добавляем вектор из шума, где третья координата всегда 0
    x(j,:) = x(j-1,:) + dt*feval(deriv,x(j-1,1:3),x(j-1,4:6),Ex,Ey)' + [sqrt_2Dx*randn*sqrt(dt) sqrt_2Dx*randn*sqrt(dt) 0 sqrt_2Dy*randn*sqrt(dt) sqrt_2Dy*randn*sqrt(dt) 0];
end

