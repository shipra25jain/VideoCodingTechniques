function [vidQuantized] = videoQuantizer(vid,stepsize)
    vidQuantized = cell(size(vid)) ;
    % Iterate over frames
    for i=1:size(vid,1)
        vidQuantized{i} = frameQuantizer(vid{i},stepsize) ;
    end
        
end