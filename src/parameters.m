
% Sampling and switching
fs = 3200; % switching frequency
Ts = 1/fs;
Ts_sim=Ts/100; % SimulaT_ion sample T_ime
Tcpu = 1/((1+sqrt(5))/2*fs*4); % dSPACE CPU update frequency should not be a multiple of controller frequency - use golden ratio for maximum irrationality

%% Power scaling
sf_i=sqrt(0.15/(5.6*250));%6/500;  % current scaling factor
sf_v=1/(250*sf_i);%1/3;    % voltage scaling factor

%% Measurement gains
GAIN_ADC=(2^16-1)/20;
GAIN_LMATR_20_AB_T=0.1;
GAIN_EXT_ADC=(2^12-1)/5;
GAIN_U_PHASE=2.55/(2.55+400);
GAIN_U_DC=5.1/(5.1+400);

%% Circuit parameters
%Nominal frequency
fn = 50;
wn = 2*pi*fn;
% LC filter
Lf_1 = 5.6e-3;
Rf_1 = 0.1;
Rf=Rf_1;
Cf_1 = 16e-6;
Cf=Cf_1;
RCf_1=0;
Lg_1 = 1e-3;
Lg=Lg_1;
Rg_1 = 0.08;
Rg=Rg_1;

% transmission line(grid impedance)
%L1 = 1.46e-3;
%R1 = 0.049;
R1 = 6.15;
L1 = 3.44e-3;
L2 = 2.93e-3;
R2 = 0.051;

% fault impedance
Rfault=0.05;
Lfault=0.5e-3;

% DC voltage source, should be clarified!!
Vdc = 800*sf_v;

% current limit
In=500e3/(3*181)*sqrt(2)*sf_i;
Ith=In*0.8;
Ilim=In;%*1.2;
Imax=19;
Rv_gain=0.01;

Pr = 2000;

%Nominal grid voltage
Vn=181*sqrt(2)*sf_v; %Peak value
%Vn = 70; %RMS
% Snubber and on-state resistances
Rsi=1e5;
Roni=1e-3;
Rsb=1e6;
Ronb=0.001;
%% Control parameters
% active power loop
kVQ=0.5;
delta_P=Pr/20;
delta_f=0.2;
kp=delta_f/delta_P;
tau2=1/(2*pi*2);
tau1=tau2/3;
Hll_droop=c2d(tf([tau1 1],[tau2 1]),Tcpu);

Htpf_droop=c2d(tf(1,[tau2*2 1]),Tcpu);

% reactive power loop
kQ=Vn*kVQ/(In);
kQi=-26;
kQp=0.36;

% Generator virtual impedance
Lv = kQ/wn;
Rv = kQ/10;

% inner current control loop - pole cancellation
T_i = 0.5*Ts;
%Kpc_1 = Lf_1/T_i;%0.64/sf_i*sf_v;
Kpc_1 = Rf_1/(exp(Rf_1/Lf_1*Ts/2)-1);
Kic_1 = (Rf_1)/T_i;%100/sf_i*sf_v;
K_vi=1/Rv;

dm= 55*pi/180;      %phase margin, typical values between 50 and 80 degrees
       
Ti_u=1/((1-sin(dm))/(T_i+T_i*sin(dm))); % time constant of the controller
        
w_c=sqrt(1/(T_i*Ti_u));                 % controller bandwidth 
        
kp_u=Cf*w_c;        % integrator gain with desired bandwidth
        
ki_u=kp_u/Ti_u;

wv=500*2*pi;

G_int=c2d(tf([wv 0],[1 wv]),Ts/2,'tustin');
%% Pre synchronization PI parameters? G_cl =(Kp_syn*s + Ki_syn) / (s^2 + Kp_syn*s + Ki_syn)
% ? = 0.707? ts = ??
% ts_syn = 1.6;
% zeta_syn = 0.707;
% wn_syn = 4.5/(ts_syn * zeta_syn);
% 
% Ki_syn = wn_syn * wn_syn;
% Kp_syn = 2 * zeta_syn * wn_syn;

%% SRF-PLL parameters
Vg = 181 * 1.414;
% Disturbance Rejection
wd = 2*pi*100;                      % Definition of 1st Harmonic Band
att_lim = 20*log10((5e-3)/(108));      % Defintion of Damping here: 5e-3 maximum tolerance and 108 V Type E negative sequence Voltage    

a = 2.4;                            % corresponds xi = 0.7

wc_lim = wd*sqrt(Vg)/sqrt(a)*10^(att_lim/40);    % calculation of bandwidth

Kp_pll = wc_lim;
wf_pll = a*wc_lim;      %1/sqrt(2)*w0;
T_L = 1/wf_pll;
Ki_pll = Kp_pll*wc_lim/a;
Ti_pll = Kp_pll/Ki_pll;

G_lpf_pll=c2d(tf(wf_pll,[1 wf_pll]),Tcpu);

discopts = c2dOptions('Method','tustin','PrewarpFrequency',wn);
G_Nari=c2d(tf([T_i 1],[Lv Rv]),Ts/2,'tustin');
s=tf('s');
G_HPF=c2d(tf([1 0],[1 2*pi*100]),Ts/2,'tustin');
w_lpf=2*pi*200;
k=15;
G_LPF=tf([k*wn 0],[1 k*wn wn^2]);
G_LPFd=c2d(tf([k*wn 0],[1 k*wn wn^2]),1e-6,'tustin');
G_LPFd2=c2d(tf([k*wn 0],[1 k*wn wn^2]),Ts/2,'tustin');

wc=1200*2*pi;
Rds=4;
G_feedback=c2d(tf(wc, [Rds wc*Rds*Cf_1+1 wc]),Ts/2,'tustin');

k=sqrt(2);
Gc_dsogi=c2d(tf([k*wn 0],[1 k*wn wn^2]),Tcpu,'tustin');
Gc_qdsogi=c2d(tf([k*wn^2],[1 k*wn wn^2]),Tcpu,'tustin');
wc=10*2*pi;
H_notch=tf([1 0 wn^2],[1 wc wn^2]);
H_lpf=1;%tf(1,[0.8/wn 1]);
Htot=c2d(H_notch*H_lpf,Ts/2);
wd=2*pi*200;
Hder=c2d(tf([wd 0],[1 wd]),Ts/2);
s_delay=0;

G_HPF=c2d(tf([1 0],[1 1.5*2*pi]),Ts/2);

w_int=2*pi*100;
Gres=c2d(tf([1/wn 0 0],[1 0 wn^2]),Tcpu);
G_vint=c2d(tf([Lf_1^2 2*Lf_1*Rf_1 Lf_1^2*wn^2+Rf_1^2],[1 w_int 0]),Tcpu);
%% 
kQi = -17;%-17;
kQp = 0.65;%0.65;

kd = 2500000;
kt = 2;
kj = 3000;
C_DC = 115e-6;

%%
%Constant or synchronverter @Michel J.Quintero-Duran et al.
J = 4.052e-4;
% Droop VSG equivalence:
% 1/(Jw) = wn*kp/T_lpf, T_lpf = 0.1s