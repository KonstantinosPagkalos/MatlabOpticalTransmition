
function [field, time] = laser(I_bias, samples, sample_freq, Pwr_dBm, plot_field)
%LASER Summary of this function goes here
%   Detailed explanation goes here
    p.g1 = 1.2e4;
    p.s = 5e-7;
    p.tph = 2e-12;
    p.tn = 2e-9;
    p.n0 = 1.5e8;
    p.aj = 2.5;
    p.bsp = 3e-5;
    p.q = 1.6e-19;
    p.dt = 1/sample_freq;
    p.I_bias = I_bias;
    % The first element is the number of carriers
    % The second element is the optical field
    y0 = [1e-10, 1e-10] + 0*1j; % Initial Conditions
    y = first_order_exponential_integrator(y0,p, samples);
    carriers = y(1,:);
    field = y(2,:);
    phase_angle = angle(field);
    field = field.*exp(-1j*phase_angle);
    time = 0:p.dt:p.dt*(samples-1);
    Pwr_field = abs(field).^2;
    Pwr_desired = 10^(Pwr_dBm/10-3);
    mean_power = mean(Pwr_field(ceil(length(field)/2):end));
    field = field*sqrt(Pwr_desired/mean_power);
    Pwr_field = abs(field).^2;
     if plot_field == 1 
        figure
        time = 0:p.dt:p.dt*(samples-1);
        plot(time*1e9, Pwr_field*1e3)
        xlabel('Time (ns)');
        ylabel('Power (mW)');
        grid on
    end
end
function [a, b] = rate_equations(y, p)
    
    carriers = real(y(1));
    field = y(2);
    
    power = abs(field)^2;
    gain_coeff = p.g1*(carriers-p.n0)/(1+p.s*power);
    Rsp = carriers/p.tn;
    
    ae = 0.5*(1+1j*p.aj)*(gain_coeff - 1/p.tph);
    be = sqrt(p.bsp*Rsp/(2*p.dt))*(randn +1j*randn);
    an = -1/p.tn - p.g1*power/(1+p.s*power);
    bn = p.I_bias/p.q + p.g1*p.n0*power/(1+p.s*power);
    
    
    a = [an, ae]';
    b = [bn, be]';

end

function y = first_order_exponential_integrator(y0, p, samples)
    
    y = zeros(length(y0),samples);
    y(:,1) = y0;

    for i=1:samples-1
       y_curr = y(:,i);
       
       [a,b] = rate_equations(y_curr, p);
       y(:,i+1)=y_curr.*exp(a*p.dt) + (b./a).*(exp(a*p.dt)-1);
    end


end

