% author: Zhao Fei 
% Date: 2019-2-20
% Description: ƥ���˲���3��ʵ�ַ�ʽ����������λ�õ�̽�� 
% This program references ���ϳɿ׾��״�����㷨��ʵ�֡�, chapter 3.
close all;clear all;

%% 1. ���ɱ�ѹ���ź�����
% ��������
N = 401;    % ÿ��������401��
N_ZD = 60;  % ��Ƶ��λ��Ŀ�������Ҳ�N_ZD��
GAP = 400;  % Ŀ����400��
K = 90;    % ��Ƶ����Ϊ100
T = 1;  % ÿ��Ŀ�����ʱ����Ϊ1s�������źŴ�-T/2������T/2
Fs = T * N; % ������
t0 = N_ZD / Fs; % ��Ƶ����ʱ���
fc = -K * t0;   % ��������Ƶ��
t_target = (-N/2:N/2-1) / Fs;
s_target = exp(1j*(2*pi*fc.*t_target + pi*K.*t_target.^2));
figure;
subplot(2,1,1);
plot(real(s_target));xlabel('ʱ�������');ylabel('����');
title('����Ŀ���ź�ʱ��');
set(gca, 'YLim', [-1.5, 2]);
subplot(2,1,2);
plot(abs(fft(s_target)));xlabel('Ƶ�ʲ�����');ylabel('����');
title('����Ŀ���ź�Ƶ��');

% �����ź�����
% s = [zeros(1,GAP), s_target, zeros(1,GAP), s_target, zeros(1,GAP), s_target];
s = s_target;
S = fft(s);
s_len = size(s, 2);

%% 2. ƥ��ѹ��
% ��ʽ1�������������ź�ʱ���ޣ�����Ȼ����Ҷ�任�õ�ƥ���˲���
h1 = [conj(s_target(end:-1:1)), zeros(1, s_len-N)];
H1 = fft(h1);
h1s = ifft(H1 .* S);


% ��ʽ2�������������źŲ�0��ֱ�Ӹ���Ҷ�任��ȡ������õ�ƥ���˲���
h2 = [s_target, zeros(1, s_len - N)];
H2 = conj(fft(h2));
h2s = ifft(H2 .* S);


% ��ʽ3����Ƶ��ֱ������ƥ���˲������˲���Ӧ�������ź�Ƶ��Ķ�����λƵ�ײ��ֻ�Ϊ���������λ�����ֲ���ֻ������ʱ��ƽ�ƣ���ѹ��Ч��û��Ӱ��
f = (-s_len/2:s_len/2-1) * Fs / s_len;
H3_tmp = exp(1j * pi .* f.^2 / K);
W3 = abs(f+K*t0)<=(abs(K)*T/2); % �������������Ƶ�Ŀ�����ڣ��������źŴ�����һ�����ڲ�������
H3 = W3 .* H3_tmp;    % �˲���Ƶ�׵���Чֵ�ֲ����ҲӦ�����źŴ�������������f��ȡֵ��ȣ�Fs������
H3 = fftshift(H3);
h3s = ifft(H3 .* S);

%% 3. ��ͼչʾ
t = (-s_len/2:s_len/2-1) / Fs;
figure;
subplot(4,1,1);
plot(real(s));ylabel('����');
title('�ź�����');
set(gca, 'YLim', [-1.5, 2]);

subplot(4,1,2);
plot(abs(h1s));ylabel('����');
title('��ʽ1ƥ���˲�������');

subplot(4,1,3);
plot(abs(h2s));ylabel('����');
title('��ʽ2ƥ���˲�������');

subplot(4,1,4);
plot(abs(h3s));xlabel('ʱ�������');ylabel('����');
title('��ʽ3ƥ���˲�������');

figure;
plot(real(H3_tmp));
hold on;
plot(W3);
title('��W3ͼ�к�ɫ���νضϵĲ����˲���Ƶ����Чֵ��֮���Ϊ��Чֵ');

