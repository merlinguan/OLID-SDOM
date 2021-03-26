function yk = sparse_transform2(xk, ft)
%% test module
% polarization modulation
% ntheta = 18;
% f = cos(2*(0:(ntheta-1))*pi/ntheta)+1;
% ft = fft(f);
% ft = reshape(ft, 1, 1, length(ft));
% % image shape
% img_shape = [50,50,18];
% psf_shape = [21,21];
% ac_shape = img_shape+[psf_shape,1]-1;
% dc_shape = ac_shape(1:2);
% slice{1} = (psf_shape(1)+1)/2:((psf_shape(1)+1)/2+img_shape(1)-1);
% slice{2} = (psf_shape(2)+1)/2:((psf_shape(2)+1)/2+img_shape(2)-1);
% % xk0-dc
% dc_tmp = zeros(img_shape(1:2));
% dc_tmp(25,15) = 2;
% xk_dc = zeros(dc_shape);
% xk_dc(slice{1}, slice{2}) = dc_tmp;
% % xk0-ac
% ac_tmp = zeros(img_shape);
% ac_tmp(25,15,1) = 1;
% ac_tmp(25,35,11) = 2;
% ac_tmp(25,35,3) = 2;
% xk_ac = zeros(ac_shape);
% xk_ac(slice{1}, slice{2}, :) = ac_tmp;
% % xk0-b
% xk_b = 0.000002;
%%
xk_dc = xk{1};
xk_ac = xk{2};
% xk_ac_conv
xk_ac_f = fft(xk_ac, [],3);
xk_ac_conv = ifft(xk_ac_f.*repmat(ft, size(xk_ac_f,1), size(xk_ac_f,2)), [], 3);
% G
g = xk_ac_conv + repmat(xk_dc, 1, 1, size(xk_ac_conv,3));
% new ac, dc
g_f = fft(g, [], 3);
g_f_mag = abs(g_f);
g_f_phase = angle(g_f);
yk_dc_mean = g_f_mag(:,:,1)/size(g_f_mag,3);
yk_ac_phase = round((mod(360-g_f_phase(:,:,2)/pi*180,360))/(360/length(ft))+1);
yk_ac_phase( yk_ac_phase>length(ft)) = 1;
yk_ac_mag = g_f_mag(:,:,2)/size(g_f_mag,3)*2;
yk_dc = yk_dc_mean-yk_ac_mag;
yk_ac = zeros(size(xk_ac));
yy = 1 : size(yk_ac,1);
xx = 1 : size(yk_ac,2);
[xx,yy] = meshgrid(xx,yy);
for kk = 1 : length(xx(:))
    yk_ac(yy(kk), xx(kk), yk_ac_phase(kk)) = yk_ac_mag(kk);
end
%%
yk{1} = yk_dc;
yk{2} = yk_ac;