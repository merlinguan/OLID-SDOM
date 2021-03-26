function void = mf2d_fista_lisdomv3(img, psf, paras, recon_dir)
%% test module
% paras.n_iter = 5000;
% paras.lk = 1;
% % image
% folder = 'I:\1_SDOM-2D\20160620_Nanoruler_120nm\LI_20_Crop\LI\';
% info = dir(folder);
% for kk = 3 : size(info,1)
%     imgtmp = imread([folder,info(kk).name]);
%     img(:,:,kk-2) = imgtmp;
% end
% img = double(img);
% % psf
% psf = imread('I:\1_SDOM-2D\20160620_Nanoruler_120nm\0_System\psf_44nm.tif');
% psf = double(psf(11:41,11:41));
% psf = psf/sum(psf(:));
%% parameters
n_iter = paras.n_iter;
lk = paras.lk;
%
global zero_tol
zero_tol = 1e-10;
%% initialization
% image shape
img_shape = size(img);
psf_shape = size(psf);
ac_shape = img_shape+[psf_shape,1]-1;
dc_shape = ac_shape(1:2);
slice{1} = (psf_shape(1)+1)/2:((psf_shape(1)+1)/2+img_shape(1)-1);
slice{2} = (psf_shape(2)+1)/2:((psf_shape(2)+1)/2+img_shape(2)-1);
% polarization modulation
ntheta = size(img,3);
f = cos(2*(0:(ntheta-1))*pi/ntheta)+1;
f = f/sum(f(:));
ft = fft(f);
ft = reshape(ft, 1, 1, length(ft));
% xk0
xk_dc = zeros(dc_shape);
xk_dc(slice{1},slice{2})=mean(img,3);
xk_ac = zeros(ac_shape);
% xk_ac(slice{1},slice{2},:)=img;
xk_b = 0;
xk = {xk_dc,xk_ac,xk_b};
% tk, yk
tkp1 = 1;
ykp1 = xk;
% df
mu = forward( xk, psf, ft, slice);
func1 = sqrt(maximumLikelihood( mu, img) / length(img(:)));
df = 0;
%% iteration
for kk = 1 : n_iter
    xkm1 = xk;
    yk = ykp1;
    tk = tkp1;
    %% find ltest and slove xk
    mu = forward( yk, psf, ft, slice);
    grad = gradient(mu, img, psf, ft, size(yk{1}));
    maxLikelihoodY = maximumLikelihood(mu, img);
    for jj = 0:1000
        ltest = lk*1.1^jj;
        xtest = step(yk, grad, ltest);
        new_mu = forward(xtest, psf, ft, slice);
        newMaxlikelihood = maximumLikelihood(new_mu, img);
        quadratic = maxLikelihoodY + quadraticApprox(xtest, yk, grad, ltest);
        if newMaxlikelihood < quadratic
            xk = xtest;
            lk = ltest;
            break;            
        end
        disp( ['ltest=', num2str(ltest), '  iter_', num2str(kk, '%.3d'), '  df=', num2str(df)])
    end
    if newMaxlikelihood >= quadratic
        disp( 'cannot find ltest')
        break;            
    end
    %% iteration and analysis
    tkp1 = 1+sqrt(1+4*tk*tk)/2;
    ykp1{1} = xk{1} + (tk-1)/tkp1*(xk{1}-xkm1{1});
    ykp1{2} = xk{2} + (tk-1)/tkp1*(xk{2}-xkm1{2});
    ykp1{3} = xk{3} + (tk-1)/tkp1*(xk{3}-xkm1{3});
    % target function
    func0 = func1;
    func1 = sqrt(maximumLikelihood( mu, img) / length(img(:)));
    df = func0 - func1;
    disp(['iter_', num2str(kk, '%.3d'), '  df=', num2str(df)])
    if mod(kk-1,10) == 0
        save([recon_dir, 'xk_', num2str(kk, '%.3d'), '.mat'], 'xk')
        sr = xk{1} + max(xk{2},[],3);
        imwrite(uint16(sr(slice{1}, slice{2})), [recon_dir, 'sr_', num2str(kk, '%.3d'), '.tif'])
        ac = max(xk{2},[],3);
        imwrite(uint16(ac(slice{1}, slice{2})), [recon_dir, 'ac_', num2str(kk, '%.3d'), '.tif'])
    end
end
void = 0;

function xk = step( yk, grad, lk)
xk{1} = yk{1}-grad{1}/lk;
xk{1} = max(xk{1}, 0);
xk{2} = yk{2}-grad{2}/lk;
xk{2} = max(xk{2}, 0);
xk{3} = yk{3}-grad{3}/lk;
xk{3} = max(xk{3}, 0);

function mu = forward(yk, psf, ft, slice)
global zero_tol
dc = yk{1};
ac = yk{2};
b = yk{3};
% cal ac
for kk = 1 : size(ac,3)
    mu_ac(:,:,kk) = conv2(ac(:,:,kk), psf, 'same');
end
mu_ac_f = fft(mu_ac, [],3);
mu_ac = ifft(mu_ac_f.*repmat(ft, size(mu_ac_f,1), size(mu_ac_f,2)), [], 3);
%cal dc
mu_dc = conv2(dc, psf, 'same');
% cal mu
mu = repmat( mu_dc, 1, 1, size(mu_ac,3)) + mu_ac + b;
mu = max(mu(slice{1}, slice{2}, :), zero_tol);


function grad = gradient(mu, img, psf, ft, g_size)
tmp = 2*(mu-img);
tmp(isinf(tmp)) = 0;
tmp(isnan(tmp)) = 0;
grad = backward(tmp, psf, ft, g_size);

function grad = backward(h, psf, ft, g_size)
% cal grad_dc
grad_dc = conv2(mean(h,3), psf, 'full');
grad{1} = grad_dc;
% cal grad_ac
grad_ac = zeros(g_size);
for kk = 1 : size(h,3)
    grad_ac(:,:,kk) = conv2(h(:,:,kk), psf, 'full');
end
grad_f = fft(grad_ac, [],3);
grad{2} = ifft(grad_f.*repmat(ft, size(grad_f,1), size(grad_f,2)), [], 3);
% cal grad_b
grad{3} = mean(h(:));

function maxLikelihood = maximumLikelihood( mu, img)
tmp = (mu-img).^2;
tmp(isinf(tmp)) = 0;
tmp(isnan(tmp)) = 0;
maxLikelihood = sum(tmp(:));

function quadratic = quadraticApprox( xk, yk, grad, lk)
delta1 = xk{1} - yk{1};
delta2 = xk{2} - yk{2};
delta3 = xk{3} - yk{3};
tmp1 = delta1.*grad{1}+lk/2*delta1.*delta1;
tmp2 = delta2.*grad{2}+lk/2*delta2.*delta2;
tmp3 = delta3.*grad{3}+lk/2*delta3.*delta3;
quadratic = sum(tmp1(:))+sum(tmp2(:))+sum(tmp3(:));
