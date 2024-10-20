function [R] = EA_MeanPhaseCoherence(data)
% Computes the Mean Phase Coherence of a pair of signals
% INPUTS:
%         - data: matrix containing a pair of signals. The matrix should be
%         2xN, where N is the number of samples
%
% OUTPUTS:
%          - R: Mean Phase Coherence number.
%
% Author: Anaïs Espinoso, 2022
% 
%--------------------------------------------------------------------------

% i) Obtantion of each signal and N
data_A = data(1,:);
data_B = data(2,:);
N = length(data_A);

% ii) Substract mean of each signal
data_A = data_A - mean(data_A);
data_B = data_B - mean(data_B);

% iii) Hilbert transform
y_A = hilbert(data_A);
y_B = hilbert(data_B);

% iv) Phase. We substract the 5% of the beginning and 5% of the end because
% the phase might be not well defined there.
phase_A = (atan2(imag(y_A),real(y_A)));
phase_A = phase_A(round(0.05*N:0.95*N));
phase_B = (atan2(imag(y_B),real(y_B)));
phase_B = phase_B(round(0.05*N:0.95*N));

% v) Mean phase coherence
Diff_AB = phase_A-phase_B;
R = abs(mean(exp(1i*Diff_AB)));

end

