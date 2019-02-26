function [vidRepRecon,totalBits] = condRep2(vid,vidMotion,stepsize,blockStatsIntra,blockStatsInter,motionStats,c)
    % Extrabits indicate mode for each block in one frame
    extraBits_frame = 144*176/(16*16)*2 ;
    vidRepRecon = cell(size(vid)) ;
    % Take first frame of the original video
    firstFrame = vid{1};
    % Intra code the first frame
    firstFrameDCTQ = frameQuantizer(frameDct(firstFrame),stepsize);
    row = size(firstFrame,1) ;
    col = size(firstFrame,2) ;
    totalBits = 0;
    % get the length of every coefficient in the first frame
    for i_1=1:row/16
        for j_1 = 1:col/16
            % Get the corresponding block in the frame
            block = firstFrameDCTQ((i_1-1)*16+1:i_1*16,(j_1-1)*16+1:j_1*16);
            % Get the bitrate/block of this specific Block
            R_block = blockrate(block,blockStatsIntra);
            totalBits = totalBits + R_block ;
        end
    end
    vidRepRecon{1} = frameiDct(firstFrameDCTQ);
    totalBits = totalBits + extraBits_frame;
    % EVERY FOLLOWING FRAME
    for i = 2:size(vid,1)
        [vidRepRecon{i},R_frame] = replacement2(vid{i},vidRepRecon{i-1},vidMotion{i},stepsize,blockStatsIntra,blockStatsInter,motionStats,c) ;
        totalBits = totalBits+R_frame ;
    end
    
end

function [repframe,R_frame] = replacement2(actual_frame,prev_frame,motion,stepsize,blockStatsIntra,blockStatsInter,motionStats,c)
    row = size(actual_frame,1) ;
    col = size(actual_frame,2) ;
    % Calculate Intra Frame
    frameIntraDCTQ = frameQuantizer(frameDct(actual_frame),stepsize);
    frameIntra = frameiDct(frameIntraDCTQ);
    frameCopy = prev_frame;
    % Calculate squared errors for whole image
    intraSE = (actual_frame-frameIntra).^2 ;
    copySE = (actual_frame-frameCopy).^2 ;
    %intraMseCell = mat2cell(intraMseCell,16*ones(row/16,1),16*ones(col/16,1))
    repframe = zeros(row,col) ;
    lambda = c*stepsize^2;
    R_frame = 0;
    % Bits needed for mode declaration
    modebits = 2;
    % Bits needed for disambiguation in INTRA mode
    disambiguity_bit = 0;
    for i=1:row/16
        for j = 1:col/16
            % Get motion vector for specific block
            motionvec = motion{i,j};
            x = motionvec(1);
            y = motionvec(2);
            % Get VLC for motion vector
            motionbits = blockrate(motionvec,motionStats);
            % Get intra blocks DCT
            blockIntraDCTQ = frameIntraDCTQ((i-1)*16+1:i*16,(j-1)*16+1:j*16);
            % Calculate residual signal of InterMode
            interBlock = prev_frame((i-1)*16+1-x:i*16-x,(j-1)*16+1-y:j*16-y);
            actualBlock = actual_frame((i-1)*16+1:i*16,(j-1)*16+1:j*16);
            interResidualBlockDCT = frameDct(actualBlock-interBlock) ;
            interResidualBlockDCTQ = frameQuantizer(interResidualBlockDCT,stepsize);
            % Calculate MSE of Reconstructed inter block
            interResidualBlockDCTRecon = frameiDct(interResidualBlockDCTQ)+prev_frame((i-1)*16+1-x:i*16-x,(j-1)*16+1-y:j*16-y);
            % D_intra
            intra_err = intraSE((i-1)*16+1:i*16,(j-1)*16+1:j*16);
            D_intra = mean(intra_err(:));
            %D_copy
            copy_err = copySE((i-1)*16+1:i*16,(j-1)*16+1:j*16); % per pixel
            D_copy = mean(copy_err(:));
            % D_inter
            inter_err = (actualBlock-interResidualBlockDCTRecon).^2;
            D_inter = mean(inter_err(:));
            %R_intra
            R_block_intra = blockrate(blockIntraDCTQ,blockStatsIntra);
            R_intra = (R_block_intra+modebits)/256;
            % R_copy
            R_copy = modebits/256; % per pixel
            % R_inter
            R_block_inter = blockrate(interResidualBlockDCTQ,blockStatsInter);
            R_inter = (R_block_inter+motionbits+modebits)/256+disambiguity_bit;
            % Calculate Laplacian
            jIntra = D_intra + lambda*R_intra ;
            jCopy = D_copy + lambda*R_copy ;
            jInter = D_inter+ lambda*R_inter ;
            if jIntra == min([jIntra,jCopy,jInter])
                R_frame = R_frame + R_intra*256;
                repframe((i-1)*16+1:i*16,(j-1)*16+1:j*16)=frameIntra((i-1)*16+1:i*16,(j-1)*16+1:j*16); 
            elseif jCopy == min([jIntra,jCopy,jInter])
                R_frame = R_frame + R_copy*256;
                repframe((i-1)*16+1:i*16,(j-1)*16+1:j*16)=frameCopy((i-1)*16+1:i*16,(j-1)*16+1:j*16); 
            elseif jInter == min([jIntra,jCopy,jInter])
                R_frame = R_frame + R_inter*256;
                repframe((i-1)*16+1:i*16,(j-1)*16+1:j*16)=interResidualBlockDCTRecon; 
            end
        end
    end
end


