function [ out1, out2 ] = simpleMatching( pos1, desc1, pos2, desc2 )

    out1 = [];
    out2 = [];
    indexTem = [];
    
    for i=1:length(pos1)
        min = 121;
        index = 1;
        leftDesc = desc1(i,:);
        for j=1:length(pos2)
            rightDesc = desc2(j,:);
            dist = sum(xor(leftDesc, rightDesc));
            if min > dist
                min = dist;
                index = j;
            end
        end
        indexTem = [indexTem; index];
%             out1 = [out1; pos1(i, :)];
%             out2 = [out2; pos2(index, :)];
    end
    for i=1:length(indexTem)
        min = 121;
        index = 1;
        leftDesc = desc2(indexTem(i),:);
        for j=1:length(pos1)
            rightDesc = desc1(j,:);
            dist = sum(xor(leftDesc, rightDesc));
            if min > dist
                min = dist;
                index = j;
            end
        end
        if index == i && min<15
            out1 = [out1; pos1(i, :)];
            out2 = [out2; pos2(indexTem(i), :)];
        end
    end

end

