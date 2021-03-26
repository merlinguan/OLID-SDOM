%% 
clc,
close all,
clear all,
%%
addpath('.\utility\')
%% INPUTS, PARAMETERS, DATA ¥¶¿Ì«∞1s
filepath = cd;
% sample dir
smpl_dir = strrep(filepath, 'program', 'dataset');
% data dir
data_dir1 = [ smpl_dir, '\4_Recon\mf2d_fista_lisdomv3_li-03s_P-2\'];
data_dir2 = [ smpl_dir, '\4_Recon\mf2d_fista_lisdomv3_li-04s_P-2\'];
data_dir3 = [ smpl_dir, '\4_Recon\mf2d_fista_lisdomv3_li-05s_P-2\'];

[s_img1,ang1,ouf1]= C4_1_DipoleDisplay(data_dir1);
[s_img2,ang2,ouf2]= C4_1_DipoleDisplay(data_dir2);
[s_img2,ang2,ouf2]= C4_1_DipoleDisplay(data_dir3);

ang_dif=mod(ang2-ang1,180);

% H=ang1/180;
% I=mat2gray(s_img1);
% S=ouf1*10/max(max(ouf1));
% hsi=cat(3,H,S,I);
% rgb=hsi2rgb(hsi);
% figure,imshow(rgb,[]);


% figure,
% imshow(ang1,[0,180]);
% figure,
% imshow(ang1,[0,180]);
% figure,
% imshow(ang_dif,[0,180]);
% imshow(ang_dif,[0,180],'colormap', autumn);
