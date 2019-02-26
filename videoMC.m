function [vidMC,vidMotion] = videoMC(vid)   
    vidMC = cell(size(vid)-1) ;
    vidMotion = cell(size(vid)-1);
    for i=size(vid,1):-1:2
        % passes every frame with its previous frame to get motion
        % compensation
         [resframe,motion]= frameBlockMC(vid{i},vid{i-1}) ;
         vidMC{i}=resframe;
         vidMotion{i}=motion;
    end
    vidMC{1} = vid{1}; 
end

function [frameMC,motionMC] = frameBlockMC(frame,prevframe)
    row = size(frame,1) ;
    col = size(frame,2) ;
    frameCell = mat2cell(frame,16*ones(row/16,1),16*ones(col/16,1)) ;
    frameCellMC = cell(size(frameCell)) ;
    motionMC = cell(size(frameCell));
    for i = 1:row/16 
        for j  = 1:col/16
            % passes every 16*16 block from current frame with previous
            % frame to compute the shift corresponding to minimum square
            % diff and also the residual block for that 16*16 block
            [resBlock,motionVec] = mc2(frameCell{i,j},prevframe,i,j) ;
            frameCellMC{i,j} = resBlock;
            motionMC{i,j} = motionVec;
        end
    end
    
    frameMC = cell2mat(frameCellMC) ;
end

function [residualBlock, motionVec] = mc2(blockMat, prevframe, i, j)
shiftX = -10:10;
shiftY = -10:10;
curX = 16*(i-1)+1;
curY = 16*(j-1)+1;
minX = NaN;
minY = NaN;
minDiff = 1000000000000.00;
for x = shiftX
    for y = shiftY
        % below line is to take care of boundary conditions
        if(curX-x>0 && curY-y>0 && curX-x+15<145 && curY-y+15<177)
            curMSE = mean(mean((prevframe(curX-x:curX-x+15,curY-y:curY-y+15)-blockMat).^2));           
            if (curMSE < minDiff)     
                minX = x;
                minY = y;
                minDiff = curMSE;
            end
        end
    end
end
% returns residual block corresponding to input block of 16*16 by taking
% difference between input block with shifted block from prev frame which
% gives minimum mean square diff
residualBlock = blockMat - prevframe(curX-minX:curX-minX+15,curY-minY:curY-minY+15);
motionVec = [minX,minY];
end