clear all
close all
set(0, 'DefaultAxesFontSize', 18);

%BASIC PARAMETERS
%%%%Camera specification
cam.f0 = 30e-3; %%focal length in[m]
cam.wid = 35e-3; %%width of sensor in [m] (also height)
cam.nPix = 512; %%number of pixels
cam.center = zeros(3,1); %%camera origin. HARD ASSUMPTION. Do not touch

fprintf('FOV of camera: %3.3f degrees\n', 2*atan(cam.wid/(2*cam.f0))*180/pi);

%%%laser proj
proj.rad = 2.5e-3; %%radius of laser beam
proj.center = [ 15e-3; 0; 0]; %%%offset in x by some amount


%%%scene
scene.name = 'VGroove';
scene.rho = 0.1; %albedo
switch scene.name
    case 'VGroove'
        scene.z0 = 300e-3; %%center depth
        scene.ang1 = 60*pi/180;
        scene.ang2 = -45*pi/180;
        
        
    case 'Sphere'
        scene.c0 = zeros(3, 1);
        scene.rad = 300e-3;
end


%%%%%%Render an image
e2d_stk = [];
e3d_stk = [];
iter = 0;

u_list = linspace(-15e-3, 10e-3, 50);



for u_indx = 1:length(u_list)
    
    u_proj =  u_list(u_indx);
    proj.d0 = [u_proj; 0; cam.f0]; 
    proj.d0 = proj.d0/norm(proj.d0);
    
    [direct, indirect, misc] = two_bounce_renderer(cam, proj, scene);
  
    %%%%%

    x3d_grtr = misc.x3d_grtr;
    c_grtr = misc.c_grtr;
    
    [c_direct, x3d_direct] = psd_3d(direct, 'none', 1, cam, proj, misc);
    [c_psd, x3d_psd] = psd_3d(direct+indirect, 'none', 1, cam, proj, misc);
    
    patt_list = [5 10 25 50 100];
    scale_list = [2 4 8 16 32 64];
    
    err2d_direct(u_indx) = norm(c_direct - c_grtr);
    err3d_direct(u_indx) = norm(x3d_direct - x3d_grtr);
    
    err2d_psd(u_indx) = norm(c_psd - c_grtr);
    err3d_psd(u_indx) = norm(x3d_psd - x3d_grtr);
    
    
    for pat_indx = 1:length(patt_list)
        for sc_indx = 1:length(scale_list)
            numPat = patt_list(pat_indx);
            sc = scale_list(sc_indx);
            patt.nPatterns = numPat;
            patt.scale = sc;
            patt.type = 'random';
            
            [c_nayar, x3d_nayar] = psd_3d(direct+indirect, 'nayar', patt, cam, proj, misc);
            [c_klotz, x3d_klotz] = psd_3d(direct+indirect, 'klotz', patt, cam, proj, misc);
    
            
            err2d_nayar(pat_indx, sc_indx, u_indx) = norm(c_nayar - c_grtr);
            err3d_nayar(pat_indx, sc_indx, u_indx) = norm(x3d_nayar - x3d_grtr);
    
            err2d_klotz(pat_indx, sc_indx, u_indx) = norm(c_klotz - c_grtr);
            err3d_klotz(pat_indx, sc_indx, u_indx) = norm(x3d_klotz - x3d_grtr);
            
        end
    end
    
    subplot 121
    plot(1, mean(err2d_direct), 'x');
    hold on
    plot(1, mean(err2d_psd), 'x');
    plot(patt_list, min(mean(err2d_nayar, 3), [], 2))
    plot(patt_list, min(mean(err2d_klotz, 3), [], 2))
    hold off
    legend('direct', 'psd', 'nayar', 'proposed')
    
    subplot 122
    plot(1, mean(err3d_direct), 'x');
    hold on
    plot(1, mean(err3d_psd(1:u_indx)), 'x');
    plot(patt_list, min(mean(err3d_nayar, 3), [], 2))
    plot(patt_list, min(mean(err3d_klotz, 3), [], 2))
    hold off
    legend('direct', 'psd', 'nayar', 'proposed')
    drawnow
end
