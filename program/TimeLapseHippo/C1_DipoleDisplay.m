%% 
clc,
close all,
clear all,
%%
addpath('.\utility\')
%% INPUTS, PARAMETERS, DATA
filepath = cd;
% sample dir
smpl_dir = strrep(filepath, 'program', 'dataset');
% data dir
data_dir = [ smpl_dir, '\3_LI\3_LI_05s\P-2\'];
% read img
info = dir( data_dir);
for kk = 3 : length( info)
    img(:,:,kk-2) = imread( [data_dir, info(kk).name]);
end
% change img to photons
img = double(img);
% img= img(64:103,170:209,:);
%% FFT
img_ft = fft(img,[],3);
img_ft_mag = abs(img_ft);
% dc image
dc_ft = img_ft;
dc_ft(:,:,2:end) = 0;
dc = ifft(dc_ft,[],3)/size(img,3)*18;
dc = dc(:,:,1);
% ac image
ac_ft = img_ft;
ac_ft(:,:,1) = 0;
ac = ifft(ac_ft,[],3)/size(img,3)*18;
% angle
ang = 45+(angle(ac_ft(:,:,2))+pi)/2/pi*180;
% ampl
ampl = max(ac,[],3);
%% Dipole Display
% ouf
ouf = ampl./dc;
% 
max_ouf = max(ouf(:));
% li
img_li = max(img,[],3);
%
vec_zoom = 5;
%
th1 = graythresh(img_li/max(img_li(:)));
mask1 = imbinarize(img_li/max(img_li(:)),th1);
th2 = graythresh(ampl/max(ampl(:)));
mask2 = imbinarize(ampl/max(ampl(:)),th2*0.1);
mask = logical(mask1.*mask2);
%
xx = 1 : size(img,2);
yy = 1 : size(img,1);
[xx,yy] = meshgrid(xx,yy);
xx = xx(mask);
yy = yy(mask);
%
figure(1)
hold off
imshow(max(img,[],3),[], 'colormap', hot)
minimg=min(min(max(img,[],3)));
% caxis([minimg,8000]);
hold on
%
v1 = ouf.*cos(ang/180*pi); v1 = v1(mask);
u1 = ouf.*sin(ang/180*pi); u1 = u1(mask);
quiver(xx,yy,v1,u1,0.5*max_ouf*vec_zoom, 'color', 'b', 'LineStyle', '-');
v2 = ouf.*cos((ang+180)/180*pi); v2 = v2(mask);
u2 = ouf.*sin((ang+180)/180*pi); u2 = u2(mask);
quiver(xx,yy,v2,u2,0.5*max_ouf*vec_zoom, 'color', 'b', 'LineStyle', '-');