function [V,M,S] = EA_CoefPhaseVelVar(data)
% Computes the coefficient of phase velocity variation (V), the mean phase velocity (M)
%  and the phase velocity standard deviation (S) of a signal
% INPUTS:
%         - data: vector of which we want to compute the univariate
%         phase-based measures
% OUTPUTS:
%          - V: coefficient of phase velocity variation.
%          - M: mean phase velocity
%          - S: phase velocity standard deviation
%
% Author: Anaïs Espinoso, 2022
%
%--------------------------------------------------------------------------

% i) Data preparation
N = length(data);
data = data - mean(data);


% ii) Hilbert transform
y = hilbert(data);

% iii) Phase
phase = (atan2(imag(y),real(y)));
phase = phase(round(0.05*N:0.95*N));


% iv) Obtation of the measures
omega = diff(unwrap(phase));
M = mean(omega);
S = std(omega);
V = S/M;

end

