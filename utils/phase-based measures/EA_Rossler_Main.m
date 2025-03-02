function [V_x,V_y,M_x,S_x,R_all,V_s_x,M_s_x,S_s_x,R_all_s] = EA_Rossler_Main(ii,E,Ey,dt,At,N,npre,dim,Max_noise_X,Max_noise_Y,Min_noise_X,Min_noise_Y,N_noise)
% Function that computes univariate phase-based measures (coefficient of
% phase velocity variation V, mean phase velocity M and phase velocity
% standard deviation S) and bivariate phase-base measure (mean phase
% coherence R) for system X and system Y from Rössler dynamics. In this
% function we generate 3-dimensional Rössler dynamics. The parameters
% needed:
%
% INPUTS:
%          - ii: number of realization. Can go from 1 to whatever desired
%          value
%          - E: coupling strength from system X -> Y.
%          - Ey: coupling strength from system Y -> X.
%          - dt: integration time step
%          - At: sampling interval
%          - N: number of datapoints for analysis Rössler dynamics
%          - npre: number of preiterations
%          - dim: number of equations
%          - Max_noise_X: maximum value of noise level applied to system X
%          - Max_noise_Y: maximum value of noise level applied to system Y
%          - Min_noise_X: maximum value of noise level applied to system X
%          - Min_noise_Y: maximum value of noise level applied to system Y
%          - N_noise: number of analysed levels of noise
%
% OUTPUTS:
%          - V_x: 2D matrix results of coefficient of phase velocity
%          variation in the first dimension of system X for different noise
%          levels applied to system X (first dimension) and to system Y
%          (second dimension).
%          - V_y: 2D matrix results of coefficient of phase velocity
%          variation in the first dimension of system Y for different noise
%          levels applied to system X (first dimension) and to system Y
%          (second dimension).
%          - M_x: 2D matrix results of mean phase velocity in the first 
%          dimension of system X for different noise levels applied to 
%          system X (first dimension) and to system Y (second dimension).
%          - S_x: 2D matrix results of phase velocity std in the first 
%          dimension of system X for different noise levels applied to 
%          system X (first dimension) and to system Y (second dimension).
%          - R: 2D matrix results of mean phase coherence between the
%          first dimension of system X and Y for different noise
%          levels applied to system X (first dimension) and to system Y
%          (second dimension).
%          - V_s_x: 3D matrix results of coefficient of phase velocity
%          variation for 19 surrogates (3rd dimension) in the first 
%          dimension of system X for different noise levels applied to 
%          system X (first dimension) and to system Y (second dimension).
%          - M_s_x: 3D matrix results of mean phase velocity for 19 
%          surrogates (3rd dimension) in the first dimension of system X 
%          for different noise levels applied to system X (first dimension) 
%          and to system Y (second dimension).
%          - S_s_x: 3D matrix results of phase velocity std for 19 
%          surrogates (3rd dimension) in the first dimension of system X 
%          for different noise levels applied to system X (first dimension) 
%          and to system Y (second dimension).
%          - R_all_s: 3D matrix results of mean phase coherence for 19 
%          surrogates (3rd dimension) in the first dimension of system X 
%          for different noise levels applied to system X (first dimension) 
%          and to system Y (second dimension).
%
%
% Example on how to call the function:
% 1) If we want same parameters as Fig.3(d)-Fig.3(f). Realization ii will
% be set to 1:
% [...] = EspinosoPRE2022_Rossler;
% 2) Same as 1) but expressing the number of realization to preserve same
% initial condition for same number of iterations. In this example,
% iteration 2:
% [...] = EspinosoPRE2022_Rossler(2)
%
% Author: Anaïs Espinoso, 2022
%--------------------------------------------------------------------------


% i) Parameters provided if no input is given (except for the number of realization).
% These parameters will generate similar results to Fig. 3(d)-Fig. 3(f)
if nargin == 0
    ii = 1; % first realization only. IMPORTANT: if this number is not changed same initial conditions will be obtained
    E = 2;
    Ey = 1;
    dt = 0.001;
    At = 0.3;
    N = 4096;
    npre = 100000;
    dim = 6;
    Max_noise_X = 2;
    Max_noise_Y = 2;
    Min_noise_X = 0;
    Min_noise_Y = 0;
    N_noise = 20;
elseif nargin == 1
    E = 2;
    Ey = 1;
    dt = 0.001;
    At = 0.3;
    N = 4096;
    npre = 100000;
    dim = 6;
    Max_noise_X = 2;
    Max_noise_Y = 2;
    Min_noise_X = 0;
    Min_noise_Y = 0;
    N_noise = 20;
end

% ii) Downsampling needed for analysis
Down= At/dt;    % downsampling needed for analysis to have less number of points
N_corrected = Down*N;     % Number of datapoints corrected for computing Rössler dynamics


% iii) Parameter of the surrogates
ParamSurro.Number = 19;        % Number of surrogates
ParamSurro.MaxIter = 120;      % Maximal Iterations
ParamSurro.type = 1;           % 1: perfect amplitudes, 2: perfect periodogram


% iv) "Seed" to obtain the same initial conditions for a given realization
rng(ii)

% v) Initialization of variables
R_all = zeros(N_noise,N_noise);
V_x = zeros(N_noise,N_noise);
V_y = zeros(N_noise,N_noise);
M_x = zeros(N_noise,N_noise);
S_x = zeros(N_noise,N_noise);
% Surrogate variables
V_s_x = zeros(N_noise,N_noise,ParamSurro.Number);
M_s_x = zeros(N_noise,N_noise,ParamSurro.Number);
S_s_x = zeros(N_noise,N_noise,ParamSurro.Number);
R_all_s = zeros(N_noise,N_noise,ParamSurro.Number);

% vi) Analysis of phase-based measures for different levels of noise X
% (sqrt_2Dx) and noise Y (sqrt_2Dy)

idx_x = 1;
for sqrt_2Dx = linspace(Min_noise_X,Max_noise_X,N_noise) % Different levels of noise X

    R = zeros(1,N_noise);
    D = zeros(1,N_noise);
    D_y = zeros(1,N_noise);
    mean_omega = zeros(1,N_noise);
    std_omega = zeros(1,N_noise);
    D_s = zeros(1,N_noise,ParamSurro.Number);
    mean_omega_s = zeros(1,N_noise,ParamSurro.Number);
    std_omega_s = zeros(1,N_noise,ParamSurro.Number);
    R_s = zeros(1,N_noise,ParamSurro.Number);

    idx_y = 1;
    for sqrt_2Dy = linspace(Min_noise_Y,Max_noise_Y,N_noise) % Different levels of noise Y

        % Initial conditions
        inicond=rand(dim,1);
        % We integrate first using as points npre to avoid transients
        [x_noise_pre, ~] = EA_Integrator_DynamicNoise(@EA_RosslerODE_bi,dim,npre,dt,inicond,E,Ey, sqrt_2Dx, sqrt_2Dy);
        % We take as new initial conditions the last states of the previous
        % integrations
        init = x_noise_pre(end,:);
        % Integration with N points
        [x_noise, ~] = EA_Integrator_DynamicNoise(@EA_RosslerODE_bi,dim,N_corrected,dt,init,E,Ey, sqrt_2Dx, sqrt_2Dy);

        % We downsample the signals of interest
        data_x_noise(1,:) = x_noise(1:Down:end,1); % System 1 first dimension
        data_x_noise(2,:) = x_noise(1:Down:end,4); % System 2 first dimension

        % Computation surrogates (1x1x19)
        D_exp_s = zeros(1,1,ParamSurro.Number);
        mean_omega_i_s = zeros(1,1,ParamSurro.Number);
        std_omega_i_s = zeros(1,1,ParamSurro.Number);
        R_exp_s = zeros(1,1,ParamSurro.Number);

        for jjj = 1:ParamSurro.Number
            DataSur = ASR_SurrogateUni(data_x_noise(1,:),ParamSurro);
            [D_exp_s(:,:,jjj),mean_omega_i_s(:,:,jjj),std_omega_i_s(:,:,jjj)] = EA_CoefPhaseVelVar(DataSur);

            DataSur_bi = ASR_SurrogateMulti(data_x_noise,ParamSurro);
            R_exp_s(:,:,jjj) = EA_MeanPhaseCoherence(DataSur_bi);
        end

        % Measures
        R_exp = EA_MeanPhaseCoherence(data_x_noise);
        [D_exp,mean_omega_i,std_omega_i] = EA_CoefPhaseVelVar(data_x_noise(1,:));
        [D_exp_y,~,~] = EA_CoefPhaseVelVar(data_x_noise(2,:));

        % Save results for noise Y
        R(idx_y) = R_exp; % 1 x N_noise
        D(idx_y) = D_exp;
        D_y(idx_y) = D_exp_y;
        mean_omega(idx_y) = mean_omega_i;
        std_omega(idx_y) = std_omega_i;
        D_s(:,idx_y,:) = D_exp_s;
        mean_omega_s(:,idx_y,:) = mean_omega_i_s;
        std_omega_s(:,idx_y,:) = std_omega_i_s;
        R_s(:,idx_y,:) = R_exp_s;

        idx_y = idx_y + 1;
        disp(['Realization = ',num2str(ii),', Noise x = ',num2str(sqrt_2Dx),' and Noise y = ',num2str(sqrt_2Dy),'...................................' ])


    end

    % Save all results 
    R_all(idx_x,:) = R; % N_noise x N_noise
    V_x(idx_x,:) = D;
    V_y(idx_x,:) = D_y;
    M_x(idx_x,:) = mean_omega;
    S_x(idx_x,:) = std_omega;
    V_s_x(idx_x,:,:) = D_s;
    M_s_x(idx_x,:,:) = mean_omega_s;
    S_s_x(idx_x,:,:) = std_omega_s;
    R_all_s(idx_x,:,:) = R_s;

    idx_x = idx_x + 1;
end


end