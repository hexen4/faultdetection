function [newsave] = pruner(e)
% Extract every 10th row
for i = 1:size(e, 1)
    for k = 1:size(e, 2)
        for l = 1:size(e, 3)
            for w = 1:size(e,4)
            newsave{i,k,l,w} = e{i,k,l,w}(1:20:end, :); 
            end
        end
    end
end
end 
