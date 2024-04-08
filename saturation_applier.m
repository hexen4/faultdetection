function [I_out] = saturation_applier(I_in)
    samples = 6269;
    S = 22;     %Inverse of sat. curve slope
    Rt = 100;    %total burden resistance
    Pf = 1;     % burden power factor
    Zb = 8;     % total burden impedance
    Tau1 = 0.038; % system time constant
    lamsat = 1.801; % peak flux linkage
    n = 600; %turns ratio
    w = 314.16;  %radian freq
    RP = 0.34584;  %RMS to peak ratio
    A = 6.95e-05; %coeff for intantaneous vs lambda curve
    dt = 0.084 / samples; %time step
    %dt = 1.184 / 1000;
    Lb = 0; %burden indunctance
    r = samples;       %no. rows per sim
    c = 6;          %no. cols per sim
    off = 0; %offset in primary current
    time = linspace(-200*dt,samples*dt,samples+201)';
    H = 1.41421 * I_in / n*(-off/Tau1*exp(-time/Tau1)+w*sin(w*time-acos(off)));
    D = zeros(samples,1);
    C = 1.41421*I_in/n*(off*exp(-time(202:end)/Tau1)-cos(w*time(202:end)-acos(off))); %
    F = zeros(samples,1);
    E = zeros(samples,1);        
    D(1) = 0.001;
    E(1) = A * sign(D(1)) * abs(D(1))^S;
    F(1) = (Rt * C(1) + Lb * H(202) - Rt * E(1)) / (1 + Lb * S * A * (abs(D(1)))^(S - 1)) * dt;
    for qw = 2:samples
        D(qw) = D(qw-1) + F(qw-1);
        E(qw) = A * sign(D(qw)) * abs(D(qw))^S;
        F(qw) = (Rt * C(qw) + Lb * H(qw + 201) - Rt * E(qw)) / (1 + Lb * S * A * (abs(D(qw)))^(S - 1)) * dt;
    end
    C = 424.27.*C; %constant, 
    E = 424.27 .* E;
    I_out = C - E;
    if I_in == 30000
        I_out = C;
    end
    if I_in == 14000
    I_out = C;
    end
    if I_in == 8000
    I_out = C;
    end
%% ROW FINDER
   % I_out = Isat(row);
  % try
   % row = find(abs(C - I_in) < 0.1);
   % catch ME
       % row  = find(abs(C - I_in) < 1);
       % row = row(1);
  % end 
   %I_out = Isat(row);
   % figure;
   %  plot(C, 'LineWidth', 2); % Plot C with a thicker line
   %  hold on; % Hold on to plot Isat on the same graph
   %  plot(I_out, 'LineWidth', 2); % Plot Isat with a thicker line
% 
%     % Enhancing the graph
%     xlabel('Time steps', 'FontSize', 12, 'FontWeight', 'bold'); % Bold X-axis label
%     ylabel('Current (A)', 'FontSize', 12, 'FontWeight', 'bold'); % Bold Y-axis label
%     legend('Unsaturated', 'Saturated', 'FontSize', 12); % Legend with adjusted font size
%     title('Current vs. Time step t=0.014 ms', 'FontSize', 14, 'FontWeight', 'bold'); % Title
% % 
% %     % Make axes bold
%     ax = gca; % Get current axes
%     ax.FontSize = 12; % Adjust font size
%     ax.FontWeight = 'bold'; % Bold font for axes numbers
% ax.LineWidth = 1.5; % Thicker axes lines
end




