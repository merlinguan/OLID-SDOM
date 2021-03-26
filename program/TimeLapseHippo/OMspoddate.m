clc;
clear all;
close all;
%%
filepath='C:\Users\95\Desktop\nmmanuscript_v6_2\SupplementarySoftware\Data\20161223_SERSnanorods_evolve_100X1.5\处理的\0处理1-40\';
savepath=[filepath,'OMSPoDfile\'];
mkdir(savepath);
for i=1:89
filename=[filepath,sprintf('%d',i),'\OM_SPoD\OM-SPoD.tif'];
img(:,:,:,i)=imread(filename);
end

for j=1:89
    imwrite(img(:,:,:,j),[savepath,sprintf('OM_SPoD%d',j),'.tif'])
end
