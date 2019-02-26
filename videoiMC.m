function [vidMCRecon] = IBlockMC(vidMCDctQuantized,vidMotion)
    vidMCQuantized = IBlockDct(vidMCDctQuantized);
    vidMCRecon = cell(size(vidMCDctQuantized));
    vidMCRecon{1} = vidMCQuantized{1};
    for frameIdx = 2:length(vidMCDctQuantized)
        motion = vidMotion{frameIdx};
        motionFrame = zeros(size(motion));
        for motionRow = 1:size(motion,1)
            for motionColumn = 1:size(motion,2)
                motionVec = motion{motionRow,motionColumn};
                curX =16*(motionRow-1)+1; 
                curY =16*(motionColumn-1)+1;
                x = motionVec(1);
                y = motionVec(2);
                prevframe = vidMCRecon{frameIdx-1};
                motionFrame(curX:curX+15,curY:curY+15) = prevframe(curX-x:curX-x+15,curY-y:curY-y+15);
            end
        end
        vidMCRecon{frameIdx} = vidMCQuantized{frameIdx}+motionFrame; 
    end
end
