function res = simulateRossler(Ex, Ey, wx, wy)
% Simulates two coupled Rossler systems with random initial conditions
x0 = rand(3, 1); % Random initial condition for system X
y0 = rand(3, 1); % Random initial condition for system Y
y0_aux = rand(3, 1); % Random initial condition for aux system Y

h = 0.03; % Integration step
nSteps = 100000; % Number of steps
t = 0:h:(nSteps-1)*h;

% Initialize solution arrays
x_res = zeros(3, nSteps);
y_res = zeros(3, nSteps);
y_res_aux = zeros(3, nSteps);
x_res(:, 1) = x0;
y_res(:, 1) = y0;
y_res_aux(:, 1) = y0_aux;

for i = 1:nSteps-1
    % Current state
    x_current = x_res(:, i);
    y_current = y_res(:, i);
    y_current_aux = y_res_aux(:, i);

    % Compute Runge-Kutta coefficients
    k1_x = h * rosslerEquation(x_current, wx, Ey, y_current(1));
    k1_y = h * rosslerEquation(y_current, wy, Ex, x_current(1));
    k1_y_aux = h * rosslerEquation(y_current_aux, wy, Ex, x_current(1));

    k2_x = h * rosslerEquation(x_current + k1_x/2, wx, Ey, y_current(1) + k1_y(1)/2);
    k2_y = h * rosslerEquation(y_current + k1_y/2, wy, Ex, x_current(1) + k1_x(1)/2);
    k2_y_aux = h * rosslerEquation(y_current_aux + k1_y_aux/2, wy, Ex, x_current(1) + k1_x(1)/2);


    k3_x = h * rosslerEquation(x_current + k2_x/2, wx, Ey, y_current(1) + k2_y(1)/2);
    k3_y = h * rosslerEquation(y_current + k2_y/2, wy, Ex, x_current(1) + k2_x(1)/2);
    k3_y_aux  = h * rosslerEquation(y_current_aux  + k2_y_aux /2, wy, Ex, x_current(1) + k2_x(1)/2);


    k4_x = h * rosslerEquation(x_current + k3_x, wx, Ey, y_current(1) + k3_y(1));
    k4_y = h * rosslerEquation(y_current + k3_y, wy, Ex, x_current(1) + k3_x(1));
    k4_y_aux = h * rosslerEquation(y_current_aux + k3_y_aux, wy, Ex, x_current(1) + k3_x(1));

    % Update state
    x_res(:, i+1) = x_current + (k1_x + 2*k2_x + 2*k3_x + k4_x) / 6;
    y_res(:, i+1) = y_current + (k1_y + 2*k2_y + 2*k3_y + k4_y) / 6;
    y_res_aux(:, i+1) = y_current_aux + (k1_y_aux + 2*k2_y_aux + 2*k3_y_aux + k4_y_aux) / 6;

end


res = [x_res(1,:); y_res(1,:); y_res_aux(1,:); t];

% figure;
% subplot(3,1,1);
% plot(t(end-2048*3:end), x_res(1, end-2048*3:end));
% xlim([t(end-2048*3), t(end)]);
% xlabel('Time [a.u.]');
% ylabel('x_1');
% 
% subplot(3,1,2);
% plot(t(end-2048*3:end), x_res(2, end-2048*3:end));
% xlim([t(end-2048*3), t(end)]);
% xlabel('Time [a.u.]');
% ylabel('x_2');
% 
% subplot(3,1,3);
% plot(t(end-2048*3:end), x_res(3, end-2048*3:end));
% xlim([t(end-2048*3), t(end)]);
% xlabel('Time [a.u.]');
% xlabel('Time');

end

function dxdt = rosslerEquation(x, w, coupling, coupledVar)
% Rossler equations with coupling
a = 0.15;
b = 0.2;
c = 10;

dx1 = -w*x(2) - x(3) + coupling * (coupledVar - x(1));
dx2 = w*x(1) + a*x(2);
dx3 = b + x(3)*(x(1) - c);

dxdt = [dx1; dx2; dx3];
end
