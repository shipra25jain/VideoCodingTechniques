function [vidDct] = videoDct(vid)
    vidDct = cell(size(vid)) ;
    % Iterate over 50 frames
    for i=1:size(vid,1)
        vidDct{i} = frameDct(vid{i,1}) ;
    end
end

