function [s_img,ang1,ouf1]=C4_1_DipoleDisplay(data_dir)
load([data_dir, 'xk_201.mat'])
s_img=imread([data_dir, 'sr_201.tif']);
s_img=s_img(153:280,470:533,:);
% read img
img=xk{1}+xk{2};  %xk2=ac,xk1=dc
img=double(img);
% size(img)
% figure(4),
% imshow(img(:,:,1),[]);
img=img(16:end-15,16:end-15,:);
img= img(153:280,470:533,:);
% figure(5),
% imshow(img(:,:,1),[]);
%%
% change img to photons
img_proc = double(img);
I0 = sum(sum(img_proc,1),2);
I0 = squeeze(I0)/I0(1);
for kk = 1 : size(img_proc,3)
    img_proc(:,:,kk) = img_proc(:,:,kk)/I0(kk);
end

%% FFT
img_ft = fft(img_proc,[],3);
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
ang = (angle(ac_ft(:,:,2))+pi)/2/pi*180;
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
%
th1 = graythresh(img_li/max(img_li(:)));
mask1 = imbinarize(img_li/max(img_li(:)),th1);
th2 = graythresh(ampl/max(ampl(:)));
mask2 = imbinarize(ampl/max(ampl(:)),th2*0.1);
mask = logical(mask1.*mask2);
ang1=ang.*mask;
ouf1=ouf.*mask;

%
xx = 1 : size(img,2);
yy = 1 : size(img,1);
[xx,yy] = meshgrid(xx,yy);
xx = xx(mask);
yy = yy(mask);

figure,
hold off
imshow(max(img,[],3),[], 'colormap', hot)
caxis([1200,3000]);
hold on
%
vec_zoom = 2;
v1 = ouf.*cos(ang/180*pi); v1 = v1(mask);
u1 = ouf.*sin(ang/180*pi); u1 = u1(mask);
quiver(xx,yy,v1,u1,0.5*max_ouf*vec_zoom, 'color', 'b', 'LineStyle', '-');
v2 = ouf.*cos((ang+180)/180*pi); v2 = v2(mask);
u2 = ouf.*sin((ang+180)/180*pi); u2 = u2(mask);
quiver(xx,yy,v2,u2,0.5*max_ouf*vec_zoom, 'color', 'b', 'LineStyle', '-');
