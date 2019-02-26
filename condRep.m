function [vidRepRecon,totalBits] = condRep(vid,stepsize,blockStats,c)
    % Extrabits indicate mode for each block in one frame
    extraBits_frame = 144*176/(16*16) ;
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
            R_block = blockrate(block,blockStats);
            totalBits = totalBits + R_block ;
        end
    end
    vidRepRecon{1} = frameiDct(firstFrameDCTQ);
    totalBits = totalBits + extraBits_frame;
    % EVERY FOLLOWING FRAME
    for i = 2:size(vid,1)
        [vidRepRecon{i} ,R_frame] = ReplacementFrame(vid{i},vidRepRecon{i-1},stepsize,blockStats,c) ;
        totalBits = totalBits+R_frame+extraBits_frame ;
    end
end

function [repFrame, R_frame] = ReplacementFrame(actual_frame,prev_frame,stepsize,blockStats,c)
    row = size(actual_frame,1) ;
    col = size(actual_frame,2) ;
    % Calculate the Intra frame 
    frameIntraDCTQ = frameQuantizer(frameDct(actual_frame),stepsize);
    frameIntra = frameiDct(frameIntraDCTQ);
    frameCopy = prev_frame;
    % Calculate squared errors for whole image
    intraSE = (actual_frame-frameIntra).^2 ;
    copySE = (actual_frame-frameCopy).^2 ;
    %intraMseCell = mat2cell(intraMseCell,16*ones(row/16,1),16*ones(col/16,1))
    indFrame = zeros(row,col) ;
    lambda = c*stepsize^2;
    R_frame = 0;
    % Mode Bits
    modebits = 1;
    for i=1:row/16
        for j = 1:col/16
            % Get intra blocks DCT
            blockIntraDCTQ = frameIntraDCTQ((i-1)*16+1:i*16,(j-1)*16+1:j*16);
            % D_intra
            intra_err = intraSE((i-1)*16+1:i*16,(j-1)*16+1:j*16);
            D_intra = mean(intra_err(:));
            %D_copy
            copy_err = copySE((i-1)*16+1:i*16,(j-1)*16+1:j*16); % per pixel
            D_copy = mean(copy_err(:));
            %R_intra
            R_block = blockrate(blockIntraDCTQ,blockStats);
            R_intra = (R_block+modebits)/256;
            % R_copy
            R_copy = modebits/256; % per pixel
            % Calculate Laplacian
            jIntra = D_intra + lambda*R_intra ;
            jCopy = D_copy + lambda*R_copy ;
            if(jIntra<jCopy)
                indFrame((i-1)*16+1:i*16,(j-1)*16+1:j*16) = ones(16,16) ;
                R_frame = R_frame+R_intra*256;
            else
                R_frame = R_frame+R_copy*256;
            end
        end
    end
    repFrame = frameIntra.*indFrame +prev_frame.*(~indFrame) ;
end


