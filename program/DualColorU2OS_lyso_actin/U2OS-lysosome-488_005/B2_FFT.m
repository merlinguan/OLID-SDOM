clear all; clc
addpath('.\utility\')
%% INPUT
filepath = cd;
% Lock In information
li_periods = 10;
li_length = 92;
fft_length = 16;
%% READ PARAMETERS
% sample dir
smpl_dir = strrep(filepath, 'program', 'dataset');
% data dir
data_dir = [smpl_dir, '\'];
sys_dir = [data_dir, '0_System\'];
% angles
load([sys_dir, '4_Angle.mat'])
img_ang = data-data(1);
for kk = 1 : length(img_ang)-1
    if img_ang(kk+1) < img_ang(kk)
        img_ang((kk+1):end) = img_ang((kk+1):end)+180;
    end
end
abs_ang = img_ang(1);
%% READ DATA
% read img
pre_dir = [data_dir, '2_Pre\'];
info = dir( pre_dir);
for kk = 3 : length( info)
    img(:,:,kk-2) = imread( [pre_dir, info(kk).name]);
end
% change img to photons
img = double(img);
% 
img_proc = img(:,:,1:li_length-1);%9,27
%%
img_ft = fft(img_proc,[],3);
img_ft_mag = abs(img_ft);
ampl = img_ft_mag(:,:,li_periods+1)/size(img_proc,3)*2;
%%
li_ft = zeros(size(img_ft,1), size(img_ft,2), fft_length);
li_ft(:,:,1) = img_ft(:,:,1);
li_ft(:,:,2) = img_ft(:,:,li_periods+1)*exp(-2i*abs_ang/180*pi);
li_ft(:,:,16) = img_ft(:,:,size(img_proc,3)+1-li_periods)*exp(2i*abs_ang/180*pi);
li = ifft(li_ft,[],3)/size(img_proc,3)*16;
li_dir = [data_dir, '3_LI\'];
save_dir = [li_dir, 'P-', num2str(li_periods), '\'];
mkdir(save_dir);
% save images
for kk = 1:fft_length
    imwrite(uint16(li(:,:,kk)), [save_dir, num2str(kk, '%.3d'), '.tif']);
end
%% save olid image
% cal dc
dc_ft = li_ft;
dc_ft(:,:,2:end) = 0;
dc = ifft(dc_ft,[],3)/size(img_proc,3)*16;
dc_img = dc(:,:,1);
ave_img = mean(img_proc,3);
% cal ac
ac_ft = li_ft;
ac_ft(:,:,1) = 0;
ac = ifft(ac_ft,[],3)/size(img_proc,3)*16;
ac_img = max(ac,[],3);
% li image
li_img = max(li,[],3);
%
std_img = std(img_proc,[],3);
%
ouf = 2*ac_img./(dc_img+ac_img);
% save images
imwrite(uint16(li_img), [li_dir, 'P-', num2str(li_periods), '-adap_li_img.tif'])
imwrite(uint16(dc_img), [li_dir, 'P-', num2str(li_periods), '-adap_dc_img.tif'])
imwrite(uint16(ave_img), [li_dir,'P-', num2str(li_periods), '-adap_ave_img.tif'])
imwrite(uint16(ac_img), [li_dir, 'P-', num2str(li_periods), '-adap_ac_img.tif'])
imwrite(uint16(std_img), [li_dir, 'P-', num2str(li_periods), '-adap_std_img.tif'])
imwrite(ouf, [li_dir, 'P-', num2str(li_periods), '-adap_ouf_img.tif'])
save([li_dir,'adap-ac_img.mat'],'ac_img');
save([li_dir,'adap-dc_img.mat'],'dc_img');