% Author: Zhao Fei 
% Date: 2019-2-16
% Description: ��б�ӽ��µľ���������㷨���� 
% This program references ���ϳɿ׾��״�����㷨��ʵ�֡�, chapter 6.
close all;clear all;
% ע�����Сб�ӽǱ仯�ǣ�1.Ҫ���ж��ξ���ѹ����2.�����㶯�����㹫ʽ�����仯��3.��λ��ѹ��ƥ���˲��������仯
%% 1. ������� (�ο� p142, table 6.1)
R_etac = 20e3;  % ������б��
Vr = 150;   % ��Ч�״��ٶ�
Tr = 2.5e-6;    % ��������ʱ��
Kr = 20e12; % �����Ƶ��
f0 = 5.3e9; % �״﹤��Ƶ��
delta_fdop = 80;    % �����մ���
Fr = 60e6;  % ���������
Fa = 100;   % ��λ������
Naz = 256;  % ��λ�����������������������
Nrg = 256;  % ��������������������߲���������
theta_rc_deg = 21.9; % ��б�ӽ�21.9��
eta_c = -49.7;   % ��������ƫ��ʱ��
f_etac = 1975;   % ����������Ƶ��
tc = 0; % tcΪ��ѡ������������Ƶʱ������������ĵ�ʱ�ӣ�s(t)=rect(t/T)exp{j*pi*K*(t-tc)^2}

c = 3e8;    % ����
lambda = c / f0;
theta_rc = theta_rc_deg * pi / 180;
Vs = Vr;
Vg = Vr;
La = 0.886 * 2 * Vs * cos(theta_rc) / delta_fdop;
beta_bw = 0.886 * lambda / La;    % we suppose
Np = Tr * Fr;   % �������г��ȣ�����������
R0c = R_etac * cos(theta_rc);   % ������б���Ӧ���б�ࣨ�����㶯У����ͼ�����Ķ�Ӧб�ࣩ
pr = c/2/Fr;    % ������������

% �趨3����Ŀ�꣺A, B, C��λ�ã����б�ࣨ��Ծ����ľ�������б�ࣩ����λ����(���A��)��
% A(-25m, 0), B(-25m, 25m), C(+25m, 50+BC*tan(theta_rc))��
NUM_TARGETS = 3;    % �����Ŀ����Ϊ3
delta_R0 = [-25, -25, 25];
R_rg = [0, 0, 40];  % ���Ǽٶ���BC��ĵؾ࣬�����ڣ�0,50��֮��
R_az = [-50, 0-R_rg(3)*tan(theta_rc), 0]; 


% ��B����������ʱ����Ϊ��λʱ��0�㣬��A,B,C����ľ����������ʱ�̷ֱ�Ϊ��
eta_ca = zeros(1, NUM_TARGETS);
for i = 1:NUM_TARGETS
    eta_ca(i) = R_az(i) / Vr;
end

% �趨�۲�ʱ���ἰ��Χ���������Ծ�����б������Ӧ����ʱ��Ϊ�۲�ʱ�����ģ�
% ��λ����A��Ĳ������Ĵ�Խʱ��Ϊ�۲�ʱ�����ģ�A��ľ����������ʱ�̼�Ϊ0��
tau = ((-Nrg / 2) : (Nrg / 2 - 1)) / Fr + R_etac * 2 / c;
eta = ((-Naz / 2 : Naz / 2 - 1)) / Fa + eta_c;

%% 2. �����״�ԭʼ����
% ʱ����������
[tauX, etaY] = meshgrid(tau, eta);
% ����A,B,C������Ը����������ʱ�̵ķ�λ��ʱ��eta
etaYs = zeros(NUM_TARGETS, Naz, Nrg);
for i = 1:NUM_TARGETS
    etaYs(i,:, :) = etaY - eta_ca(i);
end
% ����A��B��C��������б��R0���൱�ڷ���A,B,C���㣩
%=================================
R0 = R0c + delta_R0;
% R0 = R_etac + delta_R0;   % Ϊ���ܹ۲⵽�źţ�����ѡ���ַ���
%=================================
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
    w_a = sinc(0.886 / beta_bw * atan(Vg * (reshape(etaYs(i, :, :), Naz, Nrg) - eta_c) / R0(i))).^2;
    % ��λ
    theta1 = -4 * pi * f0 * reshape(R_eta(i, :, :), Naz, Nrg) / c;
    theta2 = pi * Kr * (tauX - 2 * reshape(R_eta(i, :, :), Naz, Nrg) / c).^2;
    % �źŶ���ۼ�
    s0 = s0 + A0 * w_r .* w_a .* exp(1j*theta1) .* exp(1j*theta2);
end

figure; % ���Ƶ�б�ӽ�����µ������״�ԭʼ�����ź�
subplot(221);imagesc(real(s0));ylabel('��λ��ʱ�䣨�����㣩');title('(a)ʵ��');
subplot(222);imagesc(imag(s0));title('(b)�鲿');
subplot(223);imagesc(abs(s0));xlabel('������ʱ�䣨�����㣩');ylabel('��λ��ʱ�䣨�����㣩');title('(c)����');
subplot(224);imagesc(angle(s0));xlabel('������ʱ�䣨�����㣩');title('(d)��λ');
suptitle('21.9��б�ӽ�����µ������״�ԭʼ�����źţ�ʱ��');

%% 3. ����ѹ��
% ����ƥ���˲���
tau_p = (-Np/2 : Np/2-1) / Fr;  % �������е�ʱ������
h_rc = (abs(tau_p) <= Tr/2) .* (kaiser(Np, 2.5).') .* exp(1j * pi * Kr * tau_p.^2);
% ��ʽ1���������壬���޲����������DFT�õ�Ƶ���˲���
Hrc1 = repmat(fft(conj(h_rc(end:-1:1)), Nrg), Naz, 1);
% ��ʽ2���������壬����DFT��Ȼ��ȡ������õ��˲���
Hrc2 = repmat(conj(fft(h_rc, Nrg)), Naz, 1);
% ��ʽ3����������Ƶ��������Ƶ�������˲���
f_tau = ifftshift((-Nrg/2 : Nrg/2-1) * Fr / Nrg); % ���ɾ�����Ƶ����
f_tau = f_tau + round((0 - f_tau) / Fr) * Fr;
Hrc3_tmp = exp(1j * pi .* f_tau.^2 / Kr);
W3 = abs(f_tau+Kr*tc) <= (abs(Kr)*Tr/2); % �������������Ƶ�Ŀ�����ڣ��������źŴ�����һ�����ڲ�������
Hrc3 = W3 .* Hrc3_tmp;    % �˲���Ƶ�׵���Чֵ�ֲ����ҲӦ�����źŴ�������������f��ȡֵ��ȣ�Fs������
Hrc3 = repmat(Hrc3, Naz, 1);
S0 = fft(s0.').';   % �õ�����Ƶ��λʱ���ź�

% ������ξ���ѹ���ľ���ѹ���˲�������ʽ3��
Ksrc_const = 2 * Vr^2 * f0^3 * (1-lambda^2*f_etac^2/4/Vr^2)^1.5/c/(R_etac*cos(theta_rc))/f_etac^2;
Hm = Hrc3 .* repmat(exp(-1j*pi.*f_tau.^2/Ksrc_const), Naz, 1);
s_src3 = S0 .* Hm;
s_src3 = ifft(s_src3.').'; 

% ��Ƶ��ƥ���˲�
Src = S0 .* Hrc3;
s_rc = ifft(Src.').';
N_rg = Nrg;
% N_rg = Nrg-Np+1;  % ����������
% s_rc = s_rc(:,1:N_rg);


figure; % ���Ʒ�ʽ3���ξ���ѹ����ʱ����ɵ�Ԥʱ������
subplot(121);imagesc(real(s_src3));xlabel('������ʱ�䣨�����㣩');ylabel('��λ��ʱ�䣨�����㣩');title('(c)��ʽ3���ξ���ѹ����ʵ��');
subplot(122);imagesc(abs(s_src3));xlabel('������ʱ�䣨�����㣩');ylabel('��λ��ʱ�䣨�����㣩');title('(d)��ʽ3���ξ���ѹ�������');
suptitle('21.9��б�ӽ���ʹ�÷�ʽ3���ξ���ѹ��������Ԥʧ������ʱ��');
%% 4. ��λ����Ҷ�任
Srd = fft(s_rc);
s_src3 = fft(s_src3);   % s_src3�ھ����������

figure; % ���ƾ���ѹ����Ľ��
subplot(221);imagesc(real(s_rc));ylabel('��λ��ʱ�䣨�����㣩');title('(a)���ξ���ѹ��ǰʵ����ʵ����');
subplot(222);imagesc(abs(s_rc));title('(b)���ξ���ѹ��ǰ���ȣ�ʵ����');
subplot(223);imagesc(real(Srd));xlabel('������ʱ�䣨�����㣩');ylabel('��λ��Ƶ�ʣ������㣩');title('(c)���ξ���ѹ��ǰʵ���������������');set(gca, 'YDir', 'normal');
subplot(224);imagesc(abs(Srd));xlabel('������ʱ�䣨�����㣩');title('(d)���ξ���ѹ��ǰ���ȣ������������');set(gca, 'YDir', 'normal');
suptitle('21.9��б�ӽǾ���ѹ�����źţ�ʱ��������������');
%% 5. ���ξ���ѹ������ʽ2���ڶ�άƵ����У�
S2df = fft(Srd.').'; % ʵ�ʲ����о�����Ƶ�����ѹ���󲻽��о�������Ҷ��任��������Ҳ�Ϳ������
f_eta = (ifftshift((-Naz/2 : Naz/2-1) * Fa / Naz)).';
f_eta = f_eta + round((f_etac - f_eta) / Fa) * Fa;
R0_tau = (-N_rg/2 : N_rg/2-1) * pr + R0c;
[R0_tau_grid, f_eta_grid] = meshgrid(R0_tau, f_eta);

% ���������������еľ����㶯����
D = (ones(Naz,1) - lambda^2 .* f_eta.^2 / 4 / Vr^2).^0.5;
% �������ѹ����Ƶ��Ksrc
Ksrc = 2 * Vr^2 * f0^3 .* D.^3 / c / R0c ./ f_eta.^2;
f_tau_grid = repmat(f_tau, Naz, 1);
% �������ѹ���˲���
Hsrc = exp(-1j * pi * f_tau_grid.^2 ./ repmat(Ksrc, 1, N_rg));
Ssrc = S2df .* Hsrc;    % ��άƵ������ж���ѹ��
s_src2 = ifft(Ssrc.').';

s_src = s_src2; % ʹ�÷�ʽ3��ʽ2���ɵĶ��ξ���ѹ��
figure; % ���ƾ���������������ѹ����Ͷ��ξ���ѹ����Ľ��
subplot(221);imagesc(real(Srd));ylabel('��λ��Ƶ�ʣ������㣩');title('(a)���ξ���ѹ��ǰʵ��');set(gca, 'YDir', 'normal');
subplot(222);imagesc(abs(Srd));title('(b)���ξ���ѹ��ǰ����');set(gca, 'YDir', 'normal');
subplot(223);imagesc(real(s_src));xlabel('������ʱ�䣨�����㣩');ylabel('��λ��Ƶ�ʣ������㣩');title('(c)���ξ���ѹ����ʵ��');set(gca, 'YDir', 'normal');
subplot(224);imagesc(abs(s_src));xlabel('������ʱ�䣨�����㣩');title('(d)���ξ���ѹ�������');set(gca, 'YDir', 'normal');
suptitle('21.9��б�ӽǶ��ξ���ѹ��ǰ���źŶԱȣ������������');

%% 6. �����㶯У��
% ��������㶯������
% ��б�ӽ�ʱ�Ľ���ľ����㶯��
D_grid = repmat(D, 1, N_rg);
RCM = R0_tau_grid ./ D_grid - R0_tau_grid;
RCM = RCM - (R_etac - R0c);
RCM = RCM / pr;   % �������㶯��ת��Ϊ���뵥Ԫƫ����

% �����ֵ��ϵ����
x_tmp = repmat(-4:3, 16, 1);
offset_tmp = (1:16)/16;
x_tmp = x_tmp + repmat(offset_tmp.', 1, 8);
hx = sinc(x_tmp);
x_tmp16 = x_tmp .* 16;
x_tmp16 = round(x_tmp16 + 16 * 8 / 2);
kwin = repmat(kaiser(16*8, 2.5).', 16, 1);
hx = kwin(x_tmp16) .* hx;
hx = hx ./ repmat(sum(hx, 2), 1, 8);

% ��ֵУ��
Srcmc = zeros(Naz, N_rg);  % ��ž����㶯У����Ļز��ź�
for i = 1:Naz
    for j = 1:N_rg
        offset_int = ceil(RCM(i,j));
        offset_frac = round((offset_int - RCM(i,j)) * 16);
        if offset_frac == 0
            Srcmc(i,j) = s_src(i,ceil(mod(j+offset_int-0.1,N_rg)));   % �����ź�����S1�������Լٶ�
        else
            Srcmc(i,j) = s_src(i, ceil(mod((j+offset_int-4:j+offset_int+3)-0.1,N_rg))) * hx(offset_frac,:).';
        end
        
    end
end

figure; % ���ƾ������������ľ���ѹ�㶯У����Ľ��
subplot(121);imagesc(real(Srcmc));xlabel('������ʱ�䣨�����㣩');ylabel('��λ��Ƶ�ʣ������㣩');title('(a)ʵ��');set(gca, 'YDir', 'normal');
subplot(122);imagesc(abs(Srcmc));xlabel('������ʱ�䣨�����㣩');title('(b)����');set(gca, 'YDir', 'normal');
suptitle('21.9��б�ӽǾ����㶯У�����źţ������������');

%% 6. ��λѹ��
Ka = 2 * Vr^2 / lambda ./ R0_tau_grid;
Haz = exp(1j * 4 * pi .* R0_tau_grid .* D_grid * f0 / c);   % ע��˴���λѹ���ಹ���˸�4*pi*R0*f0/c����λ
Srd_ac = Srcmc .* Haz;

%% 7. �õ�ʱ��SARͼ��
s_ac = ifft(Srd_ac);

figure; % ���Ƶ�б�ӽ�����¾���ѹ���ҷ�λѹ�����ź�
subplot(121);imagesc(real(s_ac));xlabel('������ʱ�䣨�����㣩');ylabel('��λ��ʱ�䣨�����㣩');title('(a)ʵ��');
subplot(122);imagesc(abs(s_ac));xlabel('������ʱ�䣨�����㣩');title('(b)����');
suptitle('21.9��б�ӽǾ���ѹ���ҷ�λѹ������źţ�ʱ��');

%% 8. ��Ŀ�����
%1 ����Ŀ��C��Ƶ�ף�����������������
target_c = s_ac(235-8:235+7,139-8:139+7);
% target_C = fftshift(fft2(target_c));
target_C = (fft2(target_c));
[M_C, N_C] = size(target_C);
% ��target_C��Ƶ�׼�϶�в�0
M0 = 256 - M_C;
N0 = 256 - N_C; % ������
% ������0
target_C_padr =zeros(M_C, 256);
pos = [5,5,6,7,11,12,12,12,11,10,10,9,9,8,7,6];
for i = 1:16
    target_C_padr(i,1:pos(i)) = target_C(i,1:pos(i));
    target_C_padr(i,end-(15-pos(i)):end) = target_C(i,pos(i)+1:end);
end
% ��λ����
target_C_padra = [target_C_padr(1:4,:);zeros(256-M_C,256);target_C_padr(5:end,:)];
target_c_interp = ifft2(target_C_padra);
figure; % ������Ŀ��CΪ����16*16��Ƭ��Ƶ��ͼ
colormap('gray');
imagesc((abs(target_C)));xlabel('����Ƶ�ʣ������㣩');ylabel('��λƵ�ʣ������㣩');title('Ŀ��C��Ƶ��ͼ(δfftshiftƽ�ƣ�');

figure; % ����Ŀ��Cѹ����ʱ���������
subplot(121);imagesc(abs(target_c_interp));xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');title('(a)�Ŵ���Ŀ��C');
subplot(122);contour(abs(target_c_interp),64);set(gca, 'YDir', 'reverse');xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');title('(b)�Ŵ��Ŀ��C������ͼ');
suptitle('Ŀ��Cѹ����ʱ���������');

%4 ������������Ŀ��C�ľ��뷽λ�����������λ
figure;
subplot(221);plot(20*log10(abs(target_c_interp(128,:))));xlabel('�����򣨲����㣩');ylabel('����');title('(a)�������������ͼ');
subplot(222);plot(20*log10(abs(target_c_interp(:,129))));xlabel('��λ�򣨲����㣩');ylabel('����');title('(b)��λ���������ͼ');
subplot(223);plot((angle(target_c_interp(128,:))));xlabel('�����򣨲����㣩');ylabel('��λ�����ȣ�');title('(c)��������λ����ͼ');
subplot(224);plot((angle(target_c_interp(:,129))));xlabel('��λ�򣨲����㣩');ylabel('��λ�����ȣ�');title('(d)��λ����λ����ͼ');
suptitle('Ŀ��C�İ�����λ����');



