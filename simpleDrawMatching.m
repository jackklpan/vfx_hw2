function [ output_args ] = simpleDrawMatching( im, pos1, pos2 )

    imageSize = size(im);
    toAdd = imageSize(2)/2;
    pos2(:,1) = pos2(:, 1) + toAdd;

    imshow(im);
    hold on;
    for i=1:length(pos1)
        line([floor(pos1(i,1)),floor(pos2(i,1))],[floor(pos1(i,2)),floor(pos2(i,2))]);
    end
    hold off;
    
end

