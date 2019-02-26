clear
close all ;

%% Choose either foreman or the other pic
image_foreman = true ;%&& false;

%% Reading the YUV file
if image_foreman
    vid = yuv_import_y('foreman_qcif.yuv',[176 144],50);
else
    vid = yuv_import_y('mother-daughter_qcif.yuv',[176 144],50);
end

%% Calculating the 8X8 DCT transformed coefficients
vidDct = videoDct(vid) ;

%% Store Variables
range = 3:6;
rateList = zeros(size(range,1),1) ;
psnrList = zeros(size(range,1),1) ;
intraStats = cell(size(range,1),1);
vidReconstructed = cell(size(range, 1),1);
j=1 ;
for i=range
    %% Uniform Quantizer
    stepsize = 2^i ;
    vidDctQuantized = videoQuantizer(vidDct,stepsize) ;
    
    %% Entropy Calculation
    % Get the statistical information of all blocks in the whole coded video
    statistics = dctInfo(vidDctQuantized);
    intraStats{j} = statistics;
    
    %% Rate Calculation
    framesPerSecond = 30 ;
    % TOTAL BIT CALC
    extraBits_frame = 144*176/(16*16) ;
    totalBits = 0;
    for h_1 = 1:size(vid,1)
        frame = vidDctQuantized{h_1};
        row = size(frame,1) ;
        col = size(frame,2) ;
        % FIRST FRAME INTRA
        for i_1=1:row/16
            for j_1 = 1:col/16
                block = frame((i_1-1)*16+1:i_1*16,(j_1-1)*16+1:j_1*16);
                R_block = blockrate(block,statistics);
                totalBits = totalBits + R_block ;
            end
        end
        totalBits = totalBits + extraBits_frame;
    end
    rate = totalBits/size(vid,1)*framesPerSecond/1000;
    rateList(j) = rate ;
    %% Getting reconsturcted video frames
    vidReconstructed{j} = videoiDct(vidDctQuantized);
    
    %% PSNR Calculation
    psnrList(j) = videoPSNR(vid,vidReconstructed{j}) ;
    
    %% Counter
    j=j+1 ;
end

%% Plotting
figure ;
plot(rateList,psnrList,'-o')
xlabel('Rate[kbit/s]') ;
ylabel('PSNR') ;
rates2 = rateList;
psnr2 = psnrList;
vidReconstructed2 = vidReconstructed;
save('ex2.mat','rates2','psnr2','vidReconstructed2');
save('IntraStats.mat', 'intraStats')