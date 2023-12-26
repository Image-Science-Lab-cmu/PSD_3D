clear all
close all

%BASIC PARAMETERS
%%%%Camera specification
cam.f0 = 30e-3; %%focal length in[m]
cam.wid = 35e-3; %%width of sensor in [m] (also height)
cam.nPix = 512; %%number of pixels
cam.center = zeros(3,1); %%camera origin. HARD ASSUMPTION. Do not touch


fprintf('FOV of camera: %3.3f degrees\n', 2*atan(cam.wid/(2*cam.f0))*180/pi);

%%%laser proj
proj.rad = 2.5e-3; %%radius of laser beam
proj.center = [ 5e-3; 0; 0]; %%%offset in x by some amount


%%%scene
scene.name = 'VGroove';
scene.rho = 0.1; %albedo
switch scene.name
    case 'VGroove'
        scene.z0 = 300e-3; %%center depth
        scene.ang1 = 10*pi/180;
        scene.ang2 = -45*pi/180;
        
        
    case 'Sphere'
        scene.c0 = zeros(3, 1);
        scene.rad = 300e-3;
        
    case 'ellipsoid'
        scene.c0 = zeros(3, 1);
        scene.rad
end


%%%%%%Render an image
e2d_stk = [];
e3d_stk = [];
iter = 0;

for u_proj = linspace(-15e-3, 10e-3, 40);
    proj.d0 = [u_proj; 0; cam.f0]; 
    proj.d0 = proj.d0/norm(proj.d0);
    
    [direct, indirect, misc] = two_bounce_renderer(cam, proj, scene);
    subplot 121
    imagesc([direct ]); colorbar
    subplot 122
    imagesc([indirect]); colorbar
    drawnow
    
    %%%%%
    
    [c_direct, x3d_direct] = psd_3d(direct, 'none', 0, cam, proj, misc);
    [c_psd, x3d_psd] = psd_3d(direct+indirect, 'none', 0, cam, proj, misc);
    patt.nPatterns = 20;
    patt.scale = 4;
    patt.type = 'random';
    [c_nayar, x3d_nayar] = psd_3d(direct+indirect, 'nayar', patt, cam, proj, misc);
    patt.nPatterns = 20;
    patt.scale = 16;
    patt.type = 'random';
    [c_klotz, x3d_klotz] = psd_3d(direct+indirect, 'klotz', patt, cam, proj, misc);
    
    x3d_grtr = misc.x3d_grtr;
    c_grtr = misc.c_grtr;
    
    err_2d = [  norm(c_direct-c_grtr) norm(c_psd-c_grtr)  norm(c_nayar-c_grtr)  norm(c_klotz-c_grtr)]';
    err_3d = [  norm(x3d_direct-x3d_grtr) norm(x3d_psd-x3d_grtr)  norm(x3d_nayar-x3d_grtr)  norm(x3d_klotz-x3d_grtr) ]';
    
    iter = iter + 1;
    x3d(:,:,iter) = [ x3d_grtr x3d_direct x3d_psd x3d_nayar x3d_klotz];
    c2d(:,:,iter) = [ c_grtr c_direct c_psd c_nayar c_klotz];
    
    e2d(:, iter) = err_2d;
    e3d(:, iter) = err_3d;
    
    
    
end

%plot shapes
figure
x = squeeze(x3d(:, 1, :)); plot3(x(1, :), x(2, :), x(3, :),'g-.');
hold on
x = squeeze(x3d(:, 2, :)); plot3(x(1, :), x(2, :), x(3, :),'g-.');
x = squeeze(x3d(:, 3, :)); plot3(x(1, :), x(2, :), x(3, :),'r--*');
x = squeeze(x3d(:, 4, :)); plot3(x(1, :), x(2, :), x(3, :),'m:s');
x = squeeze(x3d(:, 5, :)); plot3(x(1, :), x(2, :), x(3, :),'b-p');
legend('Gr Tr', 'Direct', 'PSD', 'Nayar', 'Proposed');
