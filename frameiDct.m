function [frame] = frameiDct(frameDct)
    row = size(frameDct,1) ;
    col = size(frameDct,2) ;
    
    frameDctCell = mat2cell(frameDct,8*ones(row/8,1),8*ones(col/8,1)) ;
    frameCell = cell(size(frameDctCell)) ;
    
    for i = 1:row/8 
        for j  = 1:col/8
            frameCell{i,j} = idct2(frameDctCell{i,j}) ;
        end
    end
    
    frame = cell2mat(frameCell) ;
end