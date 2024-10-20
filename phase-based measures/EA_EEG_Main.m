function [V,V_test,M,M_test,S,S_test,R,R_test]=EA_EEG_Main(Data,filt_idx)

% Function that computes univariate phase-based measures (coefficient of
% phase velocity variation V, mean phase velocity M and phase velocity
% standard deviation S) and bivariate phase-base measure (mean phase
% coherence R) from the public domain Bern-Barcelona database.
% This database can be found in:
%
% R. G. Andrzejak, K. Schindler, and C. Rummel, “Bern-Barcelona database,” 2012. Available:
% https://www.upf.edu/web/ntsa/downloads.
%
% If you are going to use this database, please cite:
%
% R. G. Andrzejak, K. Schindler, and C. Rummel, “Nonrandomness, nonlinear dependence,
% and nonstationarity of electroencephalographic recordings from epilepsy patients," Physical
% Review E, vol. 86, no. 4, p. 046206, 2012.
%
% If you are going to use this code please cite:
%
% (Paper Espinoso 2022 in process)
%
% INPUTS:
%         - Data: matrix 2x10240 corresponding to signal x (fisrt row)
%         and signal y (second row) from pairs of recorded EEG signals.
%         This Data can be focal or nonfocal EEG pairs from the Bern-Barcelona
%         database or from other databases.
%         - filt_idx: variable to choose filters for original signals database:
%                   -> filt_idx = 0: LPF 40 Hz and Notch
%                   -> filt_idx = 1: filter 0 + delta band
%                   -> filt_idx = 2: filter 0 + theta band
%                   -> filt_idx = 3: filter 0 + alpha band
%                   -> filt_idx = 4: filter 0 + beta band
%
% OUTPUTS:
%         - V: coefficient of phase velocity variation from signal x
%         (original signal + 19 surrogates)
%         - V_test: rejection (1) or non rejection (0) from the
%         coefficient of phase velocity variation test from signal x
%         - M: mean phase velocity from signal x
%         (original signal + 19 surrogates)
%         - M_test: rejection (1) or non rejection (0) from the mean
%         phase velocity test from signal pairs
%         - S: phase velocity standard deviation from signal x
%         (original signal + 19 surrogates)
%         - S_test: rejection (1) or non rejection (0) from the phase
%         velocity standard deviationy test from signal x
%         - R: mean phase coherence from pair of signals
%         (original signal + 19 surrogates)
%         - R_test: rejection (1) or non rejection (0) from the mean
%         phase coherence test from signal pairs
%
% Author: Anaïs Espinoso, 2022
%--------------------------------------------------------------------------

% 0) Information of signal
ASR_setParameters_Bern;

% i) Pre-filtering of LPF 40 Hz + Notch or bands

Data = ASR_Filter(Data, fs, ParamFilter,1); % Input expected: 2x10240

if filt_idx == 1 % delta band
    delta=[0.5 4];
    [B,A] = butter(3,2*delta./fs,'bandpass');
elseif filt_idx == 2 % theta band
    theta=[4 8];
    [B,A] = butter(3,2*theta./fs,'bandpass');
elseif filt_idx == 3 % alpha band
    alpha=[8 12];
    [B,A] = butter(3,2*alpha./fs,'bandpass');
elseif filt_idx == 4 % beta band
    beta=[12 31];
    [B,A] = butter(3,2*beta./fs,'bandpass');
end

if filt_idx ~= 0 % if we want to filter to some band
    filt = filtfilt(B,A,Data'); Data = filt';
end

% ii) Parameters of surrogates
ParamSurro.Number = 19;        % Number of surrogates
ParamSurro.MaxIter = 120;      % Maximal Iterations
ParamSurro.type = 1;           % 1: perfect amplitudes, 2: perfect periodogram

% iii) Computation univariate measures for original and surrogates

V = zeros(ParamSurro.Number + 1,1); % (1 original + 19 surrogates)
M = zeros(ParamSurro.Number + 1,1);
S = zeros(ParamSurro.Number + 1,1);

for s = 1:ParamSurro.Number + 1
    %(we take only the first row of Data, we want only signal x)!!!
    if s == 1 % Original signal
        Signal = Data(1,:);
    elseif s > 1 % Univariate surrogates
        Signal = ASR_SurrogateUni(Data(1,:),ParamSurro);
    end

    [V(s),M(s),S(s)] = EA_CoefPhaseVelVar(Signal);

end

% iv) Computation bivariate measure for original and surrogates

R = zeros(ParamSurro.Number + 1,1);

for s = 1:ParamSurro.Number + 1

    if s == 1 % Original signal
        Signal = Data;
    elseif s > 1 % Bivariate surrogates
        Signal = ASR_SurrogateMulti(Data,ParamSurro); % Input expected: 2x10240
    end

    R(s) = EA_MeanPhaseCoherence(Signal);

end


% v) Performance test
% We initialize all tests to 0
V_test = 0;
M_test = 0;
S_test = 0;
R_test = 0;

% Test V
if V(1) < min(V(2:ParamSurro.Number + 1))
    V_test = 1;
end


% Test M
if M(1) < min(M(2:ParamSurro.Number + 1))
    M_test = 1;
end


% Test S
if S(1) < min(S(2:ParamSurro.Number + 1))
    S_test = 1;
end


% Test R
if R(1) > max(R(2:ParamSurro.Number + 1))
    R_test = 1;
end


end