function [ perfect_sample, inlier_mean_offset, inliner_count ] = RANSAC( offset )

    maxInlier = 0;
    offset_length = length(offset);
    inlier_dist_threshold = 10;
    
    for k=1:35
        sample = offset( floor(rand()*offset_length)+1, : );
        
        nowInlier = 0;
        for i=1:offset_length
            dist_x = sample(1) - offset(i, 1);
            dist_y = sample(2) - offset(i, 2);
            distance = sqrt(dist_x^2+dist_y^2);
            
            if distance < inlier_dist_threshold
                nowInlier = nowInlier + 1;
            end
        end
        
        if nowInlier > maxInlier
            maxInlier = nowInlier;
            perfect_sample = sample;
        end
    end
    
    inliner_count = maxInlier;
    
    inlier_mean_offset = zeros(2, 1);
    for i=1:offset_length
        dist_x = perfect_sample(1) - offset(i, 1);
        dist_y = perfect_sample(2) - offset(i, 2);
        distance = sqrt(dist_x^2+dist_y^2);
        
        if distance < inlier_dist_threshold
            inlier_mean_offset(1) = inlier_mean_offset(1) + offset(i, 1);
            inlier_mean_offset(2) = inlier_mean_offset(2) + offset(i, 2);
        end
    end
    inlier_mean_offset = inlier_mean_offset / inliner_count;
    
end

