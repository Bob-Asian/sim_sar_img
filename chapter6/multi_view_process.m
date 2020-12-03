% Author: Zhao Fei 
% Date: 2019-2-16
% Description: ���Ӵ������ 
% This program references ���ϳɿ׾��״�����㷨��ʵ�֡�, chapter 6.
close all;clear all;
%% 1. ������� (���ֲο� p142, table 6.1)
R_etac = 20e3;  % ������б��
Vr = 150;   % ��Ч�״��ٶ�
Tr = 2.5e-6;    % ��������ʱ��
Kr = 20e12; % �����Ƶ��
f0 = 5.3e9; % �״﹤��Ƶ��
delta_fdop = 60;    % �����մ���
Fr = 60e6;  % ���������
Fa = 100;   % ��λ������
Naz = 512;  % ��λ�����������������������
Nrg = 1;  % ��������������������߲���������
theta_rc_deg = 0; % ��б�ӽ�0��
eta_c = 0;   % ��������ƫ��ʱ��
f_etac = 0;   % ����������Ƶ��
tc = 0; % tcΪ��ѡ������������Ƶʱ������������ĵ�ʱ�ӣ�s(t)=rect(t/T)exp{j*pi*K*(t-tc)^2}
c = 3e8;    % ����
F_L = 20;   % �����˲�������
overlap = 20e-2; % ����20%���ص�
kaiser_beta = 2;    % ���Ӵ���beta=2��kaiser��
Num_son = 3;    % ������Ŀ

% ��������
lambda = c / f0;
theta_rc = theta_rc_deg * pi / 180;
Vs = Vr;
Vg = Vr;
La = 0.886 * 2 * Vs * cos(theta_rc) / delta_fdop;
beta_bw = 0.886 * lambda / La;    % we suppose
R0c = R_etac * cos(theta_rc);   % ������б���Ӧ���б�ࣨ�����㶯У����ͼ�����Ķ�Ӧб�ࣩ
pr = c/2/Fr;    % ������������
Ta = lambda * R0c * delta_fdop / 2 / Vr^2 / cos(theta_rc)^3;    % Ŀ������ʱ��
Np = round(Tr * Fr);   % �������г��ȣ�����������
Npa = round(Ta * Fa);  % ��λ�����峤��
% �趨3����Ŀ�꣺A, B, C��λ�ã����б�ࣨ��Ծ����ľ����Ӧ���б�ࣩ����λ����(���A��)��
% A(0m, -315), B(0m, 0m), C(0m, 315m)��
% ����������ͬһ�����ϵĲ�ͬ��λ��
NUM_TARGETS = 3;    % �����Ŀ����Ϊ3
delta_R0 = [0, 0, 0];  % Ŀ�����б��
R_az = [-315, 0, 315]; % Ŀ����Է�λ�����

% ��C����������ʱ����Ϊ��λʱ��0�㣬��A,B,C����ľ����������ʱ�̷ֱ�Ϊ��
eta_ca = zeros(1, NUM_TARGETS);
for i = 1:NUM_TARGETS
    eta_ca(i) = R_az(i) / Vr;
end

% �趨ԭʼ���ݹ۲�ʱ���ἰ��Χ���������Ծ�����б������Ӧ����ʱ��Ϊ�۲�ʱ�����ģ�
% ��λ����A��Ĳ������Ĵ�Խʱ��Ϊ�۲�ʱ�����ģ�A��ľ����������ʱ�̼�Ϊ0��
tau = R_etac * 2 / c;
eta = ((-Naz / 2 : Naz / 2 - 1)) / Fa + eta_c;

%% 2. �����״�ԭʼ���ݣ�A,B,C�������б����ͬ����λ���벻ͬ��
% ʱ����������
[tauX, etaY] = meshgrid(tau, eta);
% ����A,B,C������Ը����������ʱ�̵ķ�λ��ʱ��eta
etaYs = zeros(NUM_TARGETS, Naz, Nrg);
for i = 1:NUM_TARGETS
    etaYs(i,:, :) = etaY - eta_ca(i);
end
% ����A��B��C��������б��R0���൱�ڷ���A,B,C���㣩
R0 = R0c + delta_R0;
% ����A��B,C����˲ʱб��
R_eta = zeros(NUM_TARGETS, Naz, Nrg);
for i = 1:NUM_TARGETS
    R_eta(i, :, :) = (R0(i)^2 + Vr^2 * etaYs(i,:,:).^2 ).^0.5;
end

A0 = 1;
s0 = zeros(Naz, Nrg);
for i = 1:NUM_TARGETS
    % ����
    w_r = (abs(tauX - 2 * reshape(R_eta(i, :, :), Naz, Nrg) / c) <= Tr / 2);
    % w_a = sinc(0.886 / beta_bw * atan(Vg * (reshape(etaYs(i, :, :), Naz, Nrg) - eta_c) / R0(i))).^2;
    w_a = (abs(reshape(etaYs(i, :, :), Naz, Nrg)-eta_c) < Ta/2);
    % ��λ
    theta1 = -4 * pi * f0 * reshape(R_eta(i, :, :), Naz, Nrg) / c;
    theta2 = pi * Kr * (tauX - 2 * reshape(R_eta(i, :, :), Naz, Nrg) / c).^2;
    % �źŶ���ۼ�
    s0 = s0 + A0 * w_r .* w_a .* exp(1j*theta1) .* exp(1j*theta2);
end

%% 3. ���Ӵ�����λ��ѹ������ʽ3��
S0 = fft(s0);   % �任����λƵ��
Ka = 2 * Vr^2 / lambda ./ R0c;  % ��λ��Ƶ��
f_eta = (ifftshift((-Naz/2 : Naz/2-1) * Fa / Naz)).';   % ���ɷ�λƵ���ᣬ�������������Ƶ��Ϊ0�����Բ��¹켣����
f_eta = f_eta + round((f_etac - f_eta) / Fa) * Fa;
% ƥ���˲�
Haz = exp(-1j*pi*f_eta.^2./Ka);
Sac = S0 .* Haz;
s_ac = ifft(Sac);

%  ������
TAL = (Npa-1)/2;    % ����Ϊ����������Ƶ��Ϊ0�����N_ZD=0
TAR = (Npa-1)/2;    % ��

figure;
subplot(211);plot(real(s0));set(gca,'YLim',[-1.5,1.5]);ylabel('����');title('ԭʼ����ʵ��');
subplot(212);plot(real(abs(s_ac)));xlabel('��λ��ʱ�䣨�����㣩');ylabel('����');title('ѹ��������ݣ����ӣ�');
suptitle('���Ӵ���');

%% 4. ���Ӵ���
% ���ӳ�ȡ�˲���λ���뷽λ�ź�Ƶ��֮��Ĺ�ϵ
f_eta_normal = (linspace(-Fa/2,Fa/2,Naz).');
S_amp = fftshift(abs(S0));  % �ź�fftshift��ķ�����

% 1. �������Ӵ�
Lsvw = round(F_L / Fa * Naz * (1 + overlap));
Wkaiser = kaiser(Lsvw, kaiser_beta);
Wsv = zeros(Naz, Num_son);
Fcen = [-F_L, 0, F_L];
for i = 1:Num_son
    si = floor(Fcen(i) / Fa * Naz + Naz/2 - Lsvw / 2);
    Wsv(si: si+Lsvw-1, i) = Wkaiser;
end
figure;
subplot(211);plot(f_eta_normal, S_amp);ylabel('����');title('(a)�ź�Ƶ��');
subplot(212);plot(f_eta_normal, Wsv(:,1), f_eta_normal,Wsv(:,2), f_eta_normal,Wsv(:,3));xlabel('��λƵ�ʣ������㣩');ylabel('����');title('(b)���ӳ�ȡ�˲�����λ��');
legend('����1','����2','����3');
suptitle('���ӳ�ȡ�˲���λ���뷽λ�ź�Ƶ��֮��Ĺ�ϵ');

% 2. ���ӳ�ȡ�������ݼ��
s1 = ifft(S0 .* Haz .* ifftshift(Wsv(:,1)));
s2= ifft(S0 .* Haz .* ifftshift(Wsv(:,2)));
s3 = ifft(S0 .* Haz .* ifftshift(Wsv(:,3)));
T_L = F_L / Ka; % �����˲���ʱ�򳤶�
Lsvt = round(T_L * Fa); % �����˲���ʱ���������
abandon_s1 = ones(Naz, 1);  % ��������Ĥ
abandon_s2 = ones(Naz, 1);
abandon_s3 = ones(Naz, 1);
delta_eta1_N = round((Fcen(1)-f_etac)/abs(Ka) * Fa);   % ������������ʱ����
delta_eta3_N = round((Fcen(3)-f_etac)/abs(Ka) * Fa);   % ������������ʱ����
abandon_s1(end-(Lsvt-1)+1+delta_eta1_N:end+delta_eta1_N) = zeros(Lsvt-1,1);
s2_AL = round((Lsvt-1)/2);
s2_AR = Lsvt-1-s2_AL;
abandon_s2(1:s2_AL) = zeros(s2_AL, 1);
abandon_s2(end-s2_AR+1:end) = zeros(s2_AR, 1);
abandon_s3(1+delta_eta3_N:Lsvt-1+delta_eta3_N) = zeros(Lsvt-1,1);

% 3. ����������
s1_a = abs(s1).* abandon_s1;
s2_a = abs(s2).* abandon_s2;
s3_a = abs(s3).* abandon_s3;

% 4. �������
s_a = sqrt(abs(s1_a).^2 + abs(s2_a).^2 + abs(s3_a).^2);


figure;
subplot(421);plot(abs(s1));ylabel('����');title('(a)ѹ���������1');
subplot(422);plot(s1_a);title('(b)���������������1');
subplot(423);plot(abs(s2));ylabel('����');title('(c)ѹ���������2');
subplot(424);plot(s2_a);title('(d)���������������2');
subplot(425);plot(abs(s3));xlabel('��λʱ�䣨�����㣩');ylabel('����');title('(e)ѹ���������3');
subplot(426);plot(s3_a);title('(f)���������������3');
subplot(428);plot(s_a);xlabel('��λʱ�䣨�����㣩');ylabel('����');title('(g)�������');

% figure
% plot(abandon_s1)
% hold on
% plot(abandon_s2)
% hold on
% plot(abandon_s3)

% 5. Ŀ��E��ʱ�������˲���
% ��ȡĿ��E
s_E = s0(170:335,1);
figure;
subplot(411);plot(real(s_E));ylabel('����');title('(a)Ŀ��E��ʵ��');
subplot(412);plot(real(ifft(Haz .* ifftshift(Wsv(:,1)))));ylabel('����');title('(b)����1');
subplot(413);plot((real(ifft(Haz .* ifftshift(Wsv(:,2))))));ylabel('����');title('(c)����2');
subplot(414);plot(real(ifft(Haz .* ifftshift(Wsv(:,3)))));xlabel('��λʱ�䣨�����㣩');ylabel('����');title('(d)����3');
