function [psnr] = Psnr(origVid, reconVid)
    psnrList = zeros(size(origVid,1),1) ;
    for i = 1:size(origVid,1)
        psnrList(i) = PsnrFrame(origVid{i},reconVid{i});
    end
    psnr = mean(psnrList) ;
end

function [psnr] = PsnrFrame(origFrame, reconFrame)
d = mean(((origFrame(:)-reconFrame(:)).^2)) ;
psnr = 10*log10((255^2)/d) ;
end

