function xk = mf2d_fista_lisdomv4(img, psf, paras, recon_dir)
%% test module
% paras.n_iter = 10000;
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
islice{1} = psf_shape(1):img_shape(1);
islice{2} = psf_shape(2):img_shape(2);
% polarization modulation
ntheta = size(img,3);
f = cos(2*(0:(ntheta-1))*pi/ntheta)+1;
ft = fft(f);
ft = reshape(ft, 1, 1, length(ft));
% xk0-dc
dc_tmp = zeros(img_shape(1:2));
dc_tmp(25,15) = 1;
xk_dc = zeros(dc_shape);
% xk_dc(slice{1}, slice{2}) = dc_tmp;
% xk0-ac
ac_tmp = zeros(img_shape);
ac_tmp(25,25,13) = 1;
xk_ac = zeros(ac_shape);
% xk_ac(slice{1}, slice{2}, :) = ac_tmp;
% xk
xk = {xk_dc,xk_ac};
xk = sparse_transform2(xk, ft); 
% tk, yk
tkp1 = 1;
ykp1 = xk;
% df
mu = forward( xk, psf, ft, slice);
% sect = squeeze(mu(11,:,:));
% figure(5)
% subplot(121)
% imshow(mean(mu,3),[])
% subplot(122)
% imshow(sect',[])
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
    xk = sparse_transform2(xk, ft); 
    ykp1{1} = xk{1} + (tk-1)/tkp1*(xk{1}-xkm1{1});
    ykp1{2} = xk{2} + (tk-1)/tkp1*(xk{2}-xkm1{2});
    ykp1 = sparse_transform2(ykp1, ft); 
    ykp1{1} = max(ykp1{1},0); ykp1{2}=max(ykp1{2},0);
    % target function
    func0 = func1;
    func1 = sqrt(maximumLikelihood( mu, img) / length(img(:)));
    df = func0 - func1;
    disp(['iter_', num2str(kk, '%.3d'), '  lk=', num2str(lk), ' f=', num2str(func1), '  df=', num2str(df)])
    if (mod(kk,50)==1)
        % display
        display3d_2(ykp1,71,ft,slice,recon_dir,kk);
    end
end
dc = xk{1};
ac = xk{2};
xk{1} = dc(islice{1},islice{2});
xk{2} = ac(islice{1},islice{2},:);

function xk = step( yk, grad, lk)
xk{1} = yk{1}-grad{1}/lk;
xk{1} = max(xk{1}, 0);
xk{2} = yk{2}-grad{2}/lk;
xk{2} = max(xk{2}, 0);

function mu = forward(yk, psf, ft, slice)
global zero_tol
dc = yk{1};
ac = yk{2};
% cal ac
for kk = 1 : size(ac,3)
    mu_ac(:,:,kk) = conv2(ac(:,:,kk), psf, 'same');
end
mu_ac_f = fft(mu_ac, [],3);
mu_ac = ifft(mu_ac_f.*repmat(ft, size(mu_ac_f,1), size(mu_ac_f,2)), [], 3);
%cal dc
mu_dc = conv2(dc, psf, 'same');
% cal mu
mu = repmat( mu_dc, 1, 1, size(mu_ac,3)) + mu_ac;
mu = max(mu(slice{1}, slice{2}, :), zero_tol);


function grad = gradient(mu, img, psf, ft, g_size)
tmp = 2*(mu-img);
grad = backward(tmp, psf, ft, g_size);

function grad = backward(h, psf, ft, g_size)
% cal grad_dc and grad_b
grad_dc = conv2(mean(h,3), psf, 'full');
% grad_dc = zeros(g_size(1:2));
% for kk = 1 : size(h,3)
%     grad_dc = grad_dc + conv2(h(:,:,kk), psf, 'full');
% end
grad{1} = grad_dc;
% cal grad_ac
grad_ac = zeros(g_size);
for kk = 1 : size(h,3)
    grad_ac(:,:,kk) = conv2(h(:,:,kk), psf, 'full');
end
grad_f = fft(grad_ac, [],3);
grad{2} = ifft(grad_f.*repmat(ft, size(grad_f,1), size(grad_f,2)), [], 3);


function maxLikelihood = maximumLikelihood( mu, img)
tmp = (mu-img).^2;
tmp(isinf(tmp)) = 0;
tmp(isnan(tmp)) = 0;
maxLikelihood = sum(tmp(:));

function quadratic = quadraticApprox( xk, yk, grad, lk)
delta1 = xk{1} - yk{1};
delta2 = xk{2} - yk{2};
tmp1 = delta1.*grad{1}+lk/2*delta1.*delta1;
tmp2 = delta2.*grad{2}+lk/2*delta2.*delta2;
quadratic = sum(tmp1(:))+sum(tmp2(:));