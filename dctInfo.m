function statistics = dctInfo(vid,stepsize)
if nargin <2
    stepsize = 0;
end

arr = [] ;
% Iteration over frames
for i=1:size(vid,1)
    arr = [arr getBlockSequence(vid{i},16)] ;
end
statistics = cell(size(arr,1),1) ;
% Iterate over every row
for i = 1:size(arr,1)
    sig = arr(i,:);
    if stepsize ~=0
        additional_values = max(sig)+10*stepsize:-stepsize:min(sig)-10*stepsize;
        sig = [sig, additional_values];
    end
    [value,~,ic] = unique(sig);
    count = accumarray(ic,1);
    prob = count/sum(count);
    statistics{i} = [value',prob,-log2(prob)];
end
% Calculate mean over all 256 coeffiecient in the blocks
end

% s = 16 for project
function [arr] = getBlockSequence(frame,s)
    row = size(frame,1) ;
    col = size(frame,2) ;
    arr = zeros(s*s,row/s*col/s);
    idx = 1;
    for i = 1:row/s
        for j = 1:col/s
            block = frame(s*(i-1)+1:s*i,s*(j-1)+1:s*j);
            arr(:,idx) = block(:);
            idx = idx+1;
        end
    end
end

