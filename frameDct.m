function [frameDct] = frameDct(frame)
    % Get dimensions of 1 frame
    row = size(frame,1) ;
    col = size(frame,2) ;
    % Divide the cell/frame into matrices of size 8x8
    frameCell = mat2cell(frame,8*ones(row/8,1),8*ones(col/8,1)) ;
    % Create new array for DCT coefficients 
    frameCellDct = cell(size(frameCell)) ;
    % Iterate over every created block and save coefficient
    for i = 1:row/8 
        for j  = 1:col/8
            frameCellDct{i,j} = dct2(frameCell{i,j}) ;
        end
    end
    % Create a final matrix
    frameDct = cell2mat(frameCellDct) ;
end

