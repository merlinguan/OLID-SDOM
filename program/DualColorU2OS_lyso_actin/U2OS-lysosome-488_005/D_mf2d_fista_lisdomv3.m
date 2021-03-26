clear variables
% addpath('.\utility')
%% Read Data
filepath = cd;
% sample name
smpl_dir = strrep(filepath, 'program', 'dataset');
% data directory
data_dir = [ smpl_dir, '\3_LI\P-10\'];
% psf file
psf_file = [ smpl_dir, '\0_System\psf_xy_em515_pxl67.tif'];
% recon dir
recon_dir = [ smpl_dir, '\4_Recon\mf2d_fista_lisdomv3_P-10\']; 
mkdir( recon_dir)
% read data
info = dir(data_dir);
img_num = 0;
for kk = 3 : 2 : size(info, 1)
    img_num = img_num+1;
    img(:,:,img_num) = imread( [data_dir, '\', info(kk).name]);
end
img = double(img);
img = max(img,0);
% img = max(img-1250,0);
% read psf
psf = imread( psf_file);
% psf = psf(11:21,11:21);
psf = double(psf) / sum(psf(:));
%% parameters
paras.n_iter = 50;
paras.lk = 50;
%%                 
xk = mf2d_fista_lisdomv3(img, psf, paras, recon_dir);