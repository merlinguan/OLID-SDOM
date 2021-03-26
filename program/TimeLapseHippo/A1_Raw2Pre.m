clear all; clc
%% INPUT
filepath = cd;
% relative polarization angle; system calib
abs_pol_ang = 0; %%%%
%% PARAMETERS AND DATA
% sample dir
smpl_dir = strrep(filepath, 'program', 'dataset');
% file structure
data_dir = [smpl_dir, '\'];
sys_dir = [data_dir, '0_System\'];
raw_dir = [data_dir, '1_Raw\'];
pre_dir = [data_dir, '2_Pre\'];
mkdir( pre_dir);
% files
files = dir(sys_dir);
mod_file = [sys_dir, files(3).name];
cam_file = [sys_dir, files(4).name];
% read cam sequence data
% load( cam_file);
% seq_info = data;
seq_info=ones(1200,1);
% read synchronization data
file_id = fopen(mod_file);
mod_data = textscan( file_id, '%s%s%f%f');
%% pre process
time = mod_data{2}; rot_sig = mod_data{4}; cam_sig = mod_data{3};
% ImgInfo
img_info = [];
%% process camara exposure information
cam_th = 3; cam_sig = (cam_sig > cam_th);
% calculate rising edge and falling edge
tmp = [0; cam_sig];
cam_sig = [cam_sig; 0];
difTmp = tmp - cam_sig;
cam_rise_edge = find(difTmp == -1); 
cam_fall_edge = find(difTmp == 1); cam_fall_edge = cam_fall_edge-1;
cam_pulse_pt = round((cam_rise_edge + cam_fall_edge) / 2);
%
% cam_pulse_pt = cam_pulse_pt(1:1200);
n_seq = floor( size( cam_pulse_pt, 1) / size( seq_info, 1));
%% get img name and calculate time of every img
img_num = 0;
time0 = -1;
for kk = 1 : n_seq
    for ll = 1 : size( seq_info,1)
        if seq_info(ll) == 0
            continue;
        end
        img_num = img_num + 1;
        tmp_info.name = '';
        tmp_info.seqNum = kk;
        tmp_info.seqType = '';
        tmp_info.imgNum = img_num;
        tmp_info.imgType = seq_info(ll);
        % calculate time
        tmp_info.CamPulsePt = cam_pulse_pt((kk-1)*size(seq_info,1)+ll);
        time_str = time{ cam_pulse_pt((kk-1)*size(seq_info,1)+ll)};
        data = textscan( time_str, '%d:%d:%f');
        hour = uint32(data{1}); 
        minu = uint32(data{2});
        milis = uint32(round( data{3}*1000));
        time_num = hour*3600000 + minu*60000 + milis;
        if time0 == -1
            time0 = time_num;
        end
        tmp_info.time = time_num-time0;
        img_info = [img_info; tmp_info];
    end
end
%% read polarization angle modulation information
% Threshold for TTL signals
RotTh = 3; rot_sig = (rot_sig > RotTh); 
% calculate rising edge and falling edge
tmp = [0; rot_sig];
rot_sig = [rot_sig; 0];
difTmp = tmp - rot_sig;
RotRiseEdge = find(difTmp == -1); 
% rotation start point is rising edge
RotPulsePt = RotRiseEdge;
%
for kk = 1 : size( img_info, 1)
    camPt = img_info(kk).CamPulsePt;
    rotAfterIdx = find( camPt < RotPulsePt, 1, 'first');
    rotBeforeIdx = rotAfterIdx - 1;
    pt = [RotPulsePt(rotBeforeIdx); RotPulsePt(rotAfterIdx)];
    ang = [0; 720];
    camAng = interp1( pt, ang, camPt);
    img_info(kk).ang = mod( camAng + abs_pol_ang, 180);
end
%%
data = img_info;
save( [sys_dir, '3_ImgInfo.mat'], 'data');
%%
load( [sys_dir, '3_ImgInfo.mat']);
img_info = data;
%% 
info = dir( raw_dir);
img_num = 0;
ImgList = [];
for kk = 3 : length(info)
    filename = info(kk).name;
    if strcmp( filename(end-3:end), '.tif')
        img_num = img_num + 1;
        tmpfile.name = filename;
        ImgList = [ImgList; tmpfile];
    end
end
%%
if size( img_info,1) ~= size( ImgList, 1)
    disp( 'Error!!!')
end
for kk = 1 : size( img_info, 1)
    %% cal time
    time = img_info(kk).time;
    minu = floor(double(time)/60000.0);
    sec = mod( time, 60000.0);
    ms = mod(sec, 1000.0);
    sec = floor( double(sec)/1000.0);
    img_info(kk).minu = minu;
    img_info(kk).sec = sec;
    img_info(kk).ms = ms;
    %% 
    newImgName = [num2str( img_info(kk).imgNum, '%.5d'), '_angle', num2str( round(img_info(kk).ang), '%.3d'), '_t', num2str(minu, '%.3d'), 'min', num2str( sec, '%.2d'), 's', num2str( ms, '%.3d'),  'ms.tif'];
    copyfile( [raw_dir, ImgList(kk).name], [pre_dir, newImgName])
end
%%
data = img_info;
save( [sys_dir, '3_ImgInfo.mat'], 'data');
for kk = 1 : length( img_info)
    angle(kk) = img_info(kk).ang;
end
data = angle;
save( [sys_dir, '4_Angle.mat'], 'data');