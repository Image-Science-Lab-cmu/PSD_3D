function vis = estimate_laser_scene_vis(l, n_l, x, scene)

switch scene.name
    case 'VGroove'
        vis = (sign(x(1,:))~=sign(l(1)));
        
    case 'Sphere'
        vis = 1+0*x(1,:);

end