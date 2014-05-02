
file_path = './pictures/parrington/';
image_name = 'prtn*.jpg';
files = dir([file_path, image_name]);
%files = flipud(files);

f = 706;


image1 = warp_to_cylindrical(imread([file_path, files(1).name]), f);
image2 = warp_to_cylindrical(imread([file_path, files(2).name]), f);

[image12FP, image21FP] = MSOP_Matching(image1, image2);
[best_match_sample1, average_sample1, inlier_count1, inlier_index1] = RANSAC( image12FP-image21FP );
[x, rotated, image2] = do_rotation_fit(image12FP, image21FP, image2, inlier_index1);
if rotated
    average_sample1(1) = x(3, 1);
    average_sample1(2) = x(3, 2);
end
blended_image1 = blendingImage(image1, image2, round(average_sample1(1)), round(average_sample1(2)));

origin(1) = min(0, average_sample1(1));
origin(2) = min(0, average_sample1(2));
blended_image1_origin = origin;

for i=3:length(files)
    
    image3 = warp_to_cylindrical(imread([file_path, files(i).name]), f);
    
    [image23FP, image32FP] = MSOP_Matching(image2, image3);
    [best_match_sample2, average_sample2, inlier_count2, inlier_index2] = RANSAC( image23FP-image32FP );
    [x, rotated, image3] = do_rotation_fit(image23FP, image32FP, image3, inlier_index2);
    if rotated
        average_sample2(1) = x(3, 1);
        average_sample2(2) = x(3, 2);
    end
    blended_image2 = blendingImage(image2, image3, round(average_sample2(1)), round(average_sample2(2)));

    average_sample = average_sample1+average_sample2;
    average_sample(2) = average_sample(2);
    origin(1) = min(origin(1), average_sample(1));
    origin(2) = min(origin(2), average_sample(2));
    positive_bound_add = 0;
    if average_sample(2)>0
        positive_bound_add = round(average_sample(2));
    end
    
    image2And3Overlap_x = size(image3,2)-round(abs(average_sample2(1)));
    blended_image_row = size(image3,1)+round(abs(origin(2))+positive_bound_add);
    blended_image_col = size(image3,2)+size(blended_image1,2)-image2And3Overlap_x;
    blended_image = zeros(blended_image_row, blended_image_col, 3, 'uint8');
    
    image3_new_y_origin = round(average_sample(2)-origin(2)+1);
    if average_sample2(2) > 0
        blended_image(image3_new_y_origin:size(image3,1)+image3_new_y_origin-1, 1:size(image3,2), :) = blended_image2(round(average_sample2(2)):size(image3,1)+round(average_sample2(2))-1, 1:size(image3,2), :);
    else
        blended_image(image3_new_y_origin:size(image3,1)+image3_new_y_origin-1, 1:size(image3,2), :) = blended_image2(1:size(image3,1), 1:size(image3,2), :);
    end
    blended_image1_new_y_origin = round(blended_image1_origin(2)-origin(2)+1);
    blended_image(blended_image1_new_y_origin:size(blended_image1,1)+blended_image1_new_y_origin-1, size(image3,2)+1:size(blended_image1,2)-image2And3Overlap_x+size(image3,2)+1, :) =  blended_image1(1:size(blended_image1,1), image2And3Overlap_x:size(blended_image1,2), :);
    
    blended_image1 = blended_image;
    average_sample1 = average_sample;
    blended_image1_origin = origin;
    image2 = image3;
    
end

% image_last = warp_to_cylindrical(imread([file_path, files(length(files)).name]), f);
% 
% [image1lastFP, imagelast1FP] = MSOP_Matching(image1, image_last);
% [best_match_sample1last, average_sample1last, inlier_count1last] = RANSAC( image1lastFP-imagelast1FP );

top_count = 0;
bottom_count = 0;
count_where = true;
for i=1:size(blended_image, 1)
    color = blended_image(i, 1, :);
    if count_where
        if color(1)==0 && color(2)==0 && color(3)==0
            top_count = top_count + 1;
        else
            count_where = false;
        end
    else
        if color(1)==0 && color(2)==0 && color(3)==0
            bottom_count = bottom_count + 1;
        end
    end
end

% if inlier_count1last>inlier_count1*0.5
if abs(top_count-bottom_count) > max(top_count, bottom_count)*0.5
    offset_to_draft = average_sample(2)/(size(blended_image,2)-size(image1, 2));
    %offset_to_draft = floor(offset_to_draft);
    if offset_to_draft ~= 0
        for col=size(blended_image, 2)-size(image1, 2):-1:1
            origin_col = blended_image(:, col, :);
            blended_image(:, col, :) = 0;
            %new_start_y = round(abs(average_sample(2))-offset_to_draft);
            this_time_offset = round(abs(offset_to_draft*(size(blended_image, 2)-size(image1, 2)-col+1)));
            if offset_to_draft < 0
                blended_image(this_time_offset+1:size(blended_image, 1), col, :) = origin_col(1:size(blended_image, 1)-this_time_offset, 1, :);
            elseif offset_to_draft > 0
                blended_image(1:size(blended_image, 1)-this_time_offset, col, :) = origin_col(this_time_offset+1:size(blended_image, 1), 1, :);
            end
        end
    end
end

% 
% 
% average_sample = average_sample1+average_sample2;
% origin(1) = min(average_sample1(1), average_sample(1));
% origin(2) = min(average_sample1(2), average_sample(2));
% % blended_im1_size = size(blended_image1);
% % blended_im2_size = size(blended_image2);
% positive_bound_add = 0;
% if average_sample(2)>0 && abs(origin(2))<average_sample(2)
%     positive_bound_add = average_sample(2);
% end
% blended_image = zeros(size(image3,1)+round(origin(2)+positive_bound_add), size(image3,2)+size(blended_image1,2)-size(image3,2)-round(abs(average_sample2(1))), 3, 'uint8');
% 
% blended_image(round(average_sample(2)-origin(2)+1):size(image3,1)+round(average_sample(2)-origin(2)+1)-1, 1:size(image3,2), :) = blended_image2(1:size(image3,1), 1:size(image3,2), :);
% blended_image(round(average_sample1(2)-origin(2)+1):size(blended_image1,1)+round(average_sample1(2)-origin(2)+1)-1, size(image3,2)+1:size(blended_image1,2)-(size(image3,2)-round(abs(average_sample2(1))))+size(image3,2)+1, :) =  blended_image1(1:size(blended_image1,1), (size(image3,2)-round(abs(average_sample2(1)))):size(blended_image1,2), :);