function fig = om_vec_2d( img, ori, ouf, vec_zoom)
%% test module
% clear all; clc
% img = [0,1,0;1,0,0;0,0,1];
% ori = [-1,10,-1;50,-1,-1;-1,-1,160];
% ouf = [0,0.5,0;1,0,0;0,0,0.2];
%%
%
ouf(ori ==-1) = 0;
%
fig = figure
% display image
imshow( img, [], 'InitialMagnification','fit');
colormap('Hot')
hold on
% display orientation vector
[x,y] = meshgrid( 1:size(img,2), 1:size(img, 1));
max_ouf = max(ouf(:));
v1 = ouf.*cos(ori/180*pi); 
u1 = ouf.*sin(ori/180*pi);
quiver(x,y,v1,u1,0.5*max_ouf*vec_zoom, 'color', 'b', 'LineStyle', '-');
v2 = ouf.*cos((ori+180)/180*pi); 
u2 = ouf.*sin((ori+180)/180*pi);
quiver(x,y,v2,u2,0.5*max_ouf*vec_zoom, 'color', 'b', 'LineStyle', '-');
hold off