function [cent, x3d, misc] = psd_3d(img, dg_mode, patt, cam, proj, misc);

if ~isfield(misc, 'mask')
    
    switch dg_mode
        case {'nayar', 'klotz'}
            for kk=1:patt.nPatterns
                
                mm = randn( [ ceil(size(img)/patt.scale)])>0;
                mm = kron(mm, ones(patt.scale));
                mm = circshift(mm, random('unid', patt.scale, 1, 2));
                if (kk==1)
                    mm = 1+0*mm; %%first pattern is ALL ones
                end
                mm = mm(1:size(img, 1), 1:size(img, 2));
                mask(:,:,kk) = mm;
                
                [~, meas(:, kk)]  = compute_centroid(img.*mm, misc);
                
                
            end
            misc.mask = mask;
            misc.meas = meas;
            
    end
    
end
switch dg_mode
    case 'none'
        cent = compute_centroid(img, misc);
        x3d = triangulate(cent, cam, proj);
    case 'nayar'
        meas = misc.meas;
        idx_max = 1; %%first pattern is ALL ONES (shoudld be the max value)!!!
        [~, idx_min] = min(meas(3, :));
        
        cx = (meas(1, idx_max)-2*meas(1, idx_min))/(meas(3, idx_max)-2*meas(3, idx_min));
        cy = (meas(2, idx_max)-2*meas(2, idx_min))/(meas(3, idx_max)-2*meas(3, idx_min));
        
        
        cent = [cx; cy];
        x3d = triangulate(cent, cam, proj);
        
        
    case 'klotz'
        meas = misc.meas;
        Dmat = eye(size(meas, 2));
        Dmat = [ Dmat-circshift(Dmat, [1 0]) Dmat-circshift(Dmat, [2 0])];
        meas2 = meas*Dmat;
        
        cx = (meas2(3, :)*meas2(1, :)')/(meas2(3, :)*meas2(3, :)');
        cy = (meas2(3, :)*meas2(2, :)')/(meas2(3, :)*meas2(3, :)');
        cent = [cx; cy];
        x3d = triangulate(cent, cam, proj);
end

end

function [cent, meas] = compute_centroid(img, misc)
csum = sum(sum(img));

cx = sum(sum(img.*misc.CamU));
cy = sum(sum(img.*misc.CamV));

cent = (1/csum)*[cx cy]';
meas = [cx; cy; csum];
end

function x3d = triangulate(cent, cam, proj)
c0 = cam.center;
d0 = [cent; cam.f0]; d0 = d0/norm(d0);

c1 = proj.center;
d1 = proj.d0;

Amat = [ d1 -d0];
lambda = (Amat'*Amat)\(-Amat'*[c1-c0]);

x3d = c1+lambda(1)*d1;
end


