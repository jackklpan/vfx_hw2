function [ blendedImage ] = blendingImage( im1, im2, tx, ty )

    im1_size = size(im1);
    im2_size = size(im2);
    overlap_size(2) = im2_size(2)-abs(tx);
    overlap_size(1) = im2_size(1)-abs(ty);
    blendedImage = zeros(im1_size(1)+abs(ty), im1_size(2)+abs(tx), 3, 'uint8');
    blended_size = size(blendedImage);
    
    %assign image1
    if ty <= 0
        blendedImage(abs(ty)+1:blended_size(1), blended_size(2)-im1_size(2)+1:blended_size(2), :) = im1;
    else
        blendedImage(1:blended_size(1)-ty, blended_size(2)-im1_size(2)+1:blended_size(2), :) = im1;
    end
    
    %assign image2
    if ty <= 0
        blendedImage(1:blended_size(1)-abs(ty), 1:im2_size(2), :) = im2;
    else
        blendedImage(ty+1:blended_size(1), 1:im2_size(2), :) = im2;
    end
    
    %assign overlap
    for row=1:blended_size(1)
        for col=abs(tx)+1:abs(tx)+overlap_size(2)
            if ty<=0
                im1_row = row-abs(ty);
                im2_row = row;
            else
                im1_row = row;
                im2_row = row-abs(ty);
            end
            
            im1_col = col-abs(tx);
            if im1_row<=im1_size(1) && im1_row>=1 && im1_col<=im1_size(2) && im1_col>=1
                im1_color = im1(im1_row, im1_col, :);
            else
                im1_color = im2(im2_row, col, :);
            end
            
            if im2_row<=im2_size(1) && im2_row>=1 && col<=im2_size(2) && col>=1
                im2_color = im2(im2_row, col, :);
            else
                im2_color = im1(im1_row, im1_col, :);
            end
            
            now_length = col-abs(tx);
            image1_percent = now_length/overlap_size(2);
            
            if checkFourNeighborAndSelfHaveBlack(im1, im1_row, im1_col)
                blendedImage(row, col, :) = im2_color;
            elseif checkFourNeighborAndSelfHaveBlack(im2, im2_row, col)
                blendedImage(row, col, :) = im1_color;
            else
                blendedImage(row, col, :) = im1_color*image1_percent + im2_color*(1-image1_percent);
            end
            
        end
    end

% 
%     image_size = size(im1);
%     translated_image2 = translation_image(im2, image_size(2)-tx, ty);
%     %translated_image2 = translated_image2(:, (image_size(2)-tx):image_size(2), :);
%     blendingImage = [translated_image2(1:image_size(1), (image_size(2)-tx)+1:image_size(2), :) im1];
%     blendingImage_size = size(blendingImage);
%     
%     overlap_length = image_size(2)-tx;
%     for row=1:blendingImage_size(1)
%         for col=tx:image_size(2)
%             now_length = col-tx;
%             image1_percent = now_length/overlap_length;
%             blendingImage(row, col, :) = im1(row, col-tx+1, :)*image1_percent + translated_image2(row, col+overlap_length, :)*(1-image1_percent);
%         end
%     end

end

function [ result ] = checkFourNeighborAndSelfHaveBlack(image, row, col)

    im_size = size(image);
    if row<=im_size(1) && row>=1 && col<=im_size(2) && col>=1
        color = image(row, col, :);
        if color(1)==0 && color(2)==0 && color(3)==0
            result = true;
            return;
        end
    else
        result = false;
        return;
    end

    if row-1<=im_size(1) && row-1>=1 && col<=im_size(2) && col>=1
        color = image(row-1, col, :);
        if color(1)==0 && color(2)==0 && color(3)==0
            result = true;
            return;
        end
    end
    if row+1<=im_size(1) && row+1>=1 && col<=im_size(2) && col>=1
        color = image(row+1, col, :);
        if color(1)==0 && color(2)==0 && color(3)==0
            result = true;
            return;
        end
    end
    if row<=im_size(1) && row>=1 && col-1<=im_size(2) && col-1>=1
        color = image(row, col-1, :);
        if color(1)==0 && color(2)==0 && color(3)==0
            result = true;
            return;
        end
    end
    if row<=im_size(1) && row>=1 && col+1<=im_size(2) && col+1>=1
        color = image(row, col+1, :);
        if color(1)==0 && color(2)==0 && color(3)==0
            result = true;
            return;
        end
    end
    
    result = false;
    
end

