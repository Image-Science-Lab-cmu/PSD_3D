function [direct, indirect, misc] = two_bounce_renderer(cam, proj, scene)


%generate points on image plane
[CamU, CamV] = meshgrid(linspace(-cam.wid/2, cam.wid/2, cam.nPix));
p = [CamU(:) CamV(:) cam.f0*ones(cam.nPix^2, 1)]';

w_p = normalize_columns(p); %%camera center is hard coded to zero
[x, n_x] = intersect_ray_with_scene(p, w_p, scene);

[l, n_l] = intersect_ray_with_scene(proj.center, proj.d0, scene);

laser_strength = n_l'*(-proj.d0);

%%make direct image
l_scene_int = cylinder_intersect(proj.center, proj.d0, proj.rad, x);
direct = laser_strength*scene.rho*l_scene_int.*(w_p(3, :).^2); 

%%indirect image
l_x_dis = 1e-10+sqrt(sum( (x - l*ones(1, size(x, 2))).^2, 1));
visibility = estimate_laser_scene_vis(l, n_l, x, scene);


cos_x = max(0, sum(n_x.*(l*ones(1, size(x, 2))-x),1))./l_x_dis;
cos_l = max(0, n_l'*(x - l*ones(1, size(x, 2))))./l_x_dis;
laser_area = (pi*proj.rad^2)/(-n_l'*proj.d0);

indirect = laser_strength*(scene.rho^2).*(w_p(3, :).^2).* ...
    laser_area.*cos_x.*cos_l.*visibility./(l_x_dis.^2);


%wrap up
direct = reshape(direct, cam.nPix, cam.nPix);
indirect = reshape(indirect, cam.nPix, cam.nPix);

[xx, yy] = meshgrid(-10:10);
fil = exp(-(xx.^2+yy.^2)/5);

direct = conv2(direct, fil, 'same');
indirect = conv2(indirect, fil, 'same');



misc.CamU = CamU;
misc.CamV = CamV;
misc.CamZ = 0*CamU+cam.f0;

misc.x3d_grtr = l;
misc.c_grtr = l(1:2)/l(3)*cam.f0;

end

function yy = normalize_columns(xx)
yy = xx./(1e-12+ones(size(xx, 1), 1)*sqrt(sum(xx.^2, 1)));
end

function int_indx = cylinder_intersect(c0, d0, rad, x);

d1 = randn(3,1); d1 = normalize_columns(d1);

d1 = d1 - (d1'*d0)*d0;
d1 = normalize_columns(d1);

d2 = cross(d0, d1);

x = x - c0*ones(1, size(x, 2));
y = [d1 d2]'*x;
int_indx = (sum(y.^2, 1) <= rad^2);
end
