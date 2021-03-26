function sect = display3d_2(x, idx, ft, slice, recon_dir,kk)
% % display
% fig = figure(5);
% fig.Color = [1,1,1];
% subplot(231)
% tmp = x{1}+max(x{2},[],3);
% imshow(tmp(slice{1},slice{2}),[])
% subplot(232)
% tmp = x{1};
% imshow(tmp(slice{1},slice{2}),[])
% subplot(233)
% tmp = max(x{2},[],3);
% imshow(tmp(slice{1},slice{2}),[])
% subplot(234)
% g_ac = x{2};
% g_ac_f = fft(g_ac, [],3);
% G_ac = ifft(g_ac_f.*repmat(ft, size(g_ac_f,1), size(g_ac_f,2)), [], 3);
% sect = squeeze(G_ac(idx,slice{2},:));
% imshow(sect',[])
% subplot(235)
% sect = squeeze(x{2}(idx,slice{2},:));
% imshow(sect', [])
% sect = sect';
% save results
sr = x{1}+max(x{2},[],3);
sr = sr(slice{1},slice{2});
sr = sr/max(sr(:))*65535;
imwrite(uint16(sr), [recon_dir, 'iter_',num2str(kk),'.tif'])
save([recon_dir, 'iter_',num2str(kk),'.mat'], 'x')