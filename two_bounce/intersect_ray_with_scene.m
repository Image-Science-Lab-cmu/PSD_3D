function [pts, normals] = intersect_ray_with_scene(p, w_p, scene)


switch scene.name
    case 'VGroove'
        z0 = scene.z0;
        ang1 = scene.ang1;
        ang2 = scene.ang2;
        
        X = p(1, :); DX = w_p(1,:);
        Y = p(2, :); DY = w_p(2,:);
        Z = p(3, :); DZ = w_p(3,:);
        
        
        lambda1 = (Z - z0 - X*tan(ang1))./(1e-8+DX*tan(ang1)-DZ);
        lambda2 = (Z - z0 - X*tan(ang2))./(1e-8+DX*tan(ang2)-DZ);
        
        
        pts1 = p + w_p.*(ones(3, 1)*lambda1);
        pts2 = p + w_p.*(ones(3, 1)*lambda2);
        
        zbuff = pts1(3, :) < pts2(3, :);
        zbuff0 = ones(3, 1)*zbuff;
        pts = zbuff.*pts1 + (1-zbuff).*pts2;
        
        nfun = @(X) [sin(scene.ang1); 0 ; -cos(scene.ang1)]*(X(1,:) < 0) +  [sin(scene.ang2); 0 ; -cos(scene.ang2)]*(X(1,:) >= 0);
        normals = nfun(pts);
        
        
    case 'Sphere'
        X0 = p;
        D0 = w_p;
        
        R = scene.rad;
        c0 = scene.c0;
        X1 = X0 - c0*ones(1, size(X0, 2));
        
        a = 1;
        b = 2*sum(X0.*D0, 1);
        c = sum(X0.^2, 1)-R^2;
        
        lambda = (-b + (b.^2 - 4.*a.*c).^(1/2))./(2*a);
        pts = X0 + D0.*(ones(3, 1)*lambda);
        
        

        normals = c0*ones(1, size(pts, 2))-pts;
        normals = normalize_columns(normals);

end


end



function yy = normalize_columns(xx)
yy = xx./(1e-12+ones(size(xx, 1), 1)*sqrt(sum(xx.^2, 1)));
end