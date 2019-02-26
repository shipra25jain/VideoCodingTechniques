function [ vid ] = videoiDct( vidDct )
    vid = cell(size(vidDct)) ;
    for i=1:size(vid,1)
        vid{i} = frameiDct(vidDct{i}) ;
    end
end





