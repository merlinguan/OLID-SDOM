clear variables
addpath('.\utility')
%% Read Data
filepath = cd;
% sample name
smpl_dir = strrep(filepath, 'program', 'dataset');
% data directory
data_dir = [ smpl_dir, '\3_LI\3_LI_31s\P-2\'];
% psf file
psf_file = [ smpl_dir, '\0_System\psf_xy_em600_pxl72.tif'];
% recon dir
recon_dir = [ smpl_dir, '\4_Recon\mf2d_fista_lisdomv3_li-31s_P-2\']; 
mkdir(recon_dir)
% read data
info = dir(data_dir);
img_num = 0;
for kk = 3 : 2 : size(info, 1)
    img_num = img_num+1;
    img(:,:,img_num) = imread( [data_dir, '\', info(kk).name]);
end
img = double(img);
% img = max(img,1000);
% img = max(img-1250,0);
% read psf
psf = imread( psf_file);
psf = double(psf) / sum(psf(:));
%% parameters
paras.n_iter = 300;
paras.lk = 100;
%%                 
xk = mf2d_fista_lisdomv3(img, psf, paras, recon_dir);