clear
close all ;

%% Choose either foreman or the other pic
image_foreman =  true ;% && false;

%% Reading the YUV file
if image_foreman
    vid = yuv_import_y('foreman_qcif.yuv',[176 144],50);
else
    vid = yuv_import_y('mother-daughter_qcif.yuv',[176 144],50);
end

%% Store Variables
range = 3:6;
rateList = zeros(size(range,1),1) ;
psnrList = zeros(size(range,1),1) ;
vidReconstructed = cell(size(range, 1),1);
j=1 ;

% Load statistics of intra frames from Ex2
load('IntraStats.mat')
for i=range
    %% Uniform Quantizer
    stepsize = 2^i ;
    
    %% Load statistics for range
    blockStats = intraStats{j};
       
    %% Rate Calculation
    framesPerSecond = 30 ;
    c = 0.2   ; % Lambda = c*Q^2
    [vidReconstructed{j},totalBits] = condRep(vid,stepsize,blockStats,c);
    rate = totalBits/size(vid,1)*framesPerSecond/1000 ; %rate in kbits/sec for 30 frames/sec
    rateList(j) = rate ;
    
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
rates3 = rateList;
psnr3 = psnrList;
vidReconstructed3 = vidReconstructed;
save('ex3.mat','rates3','psnr3','vidReconstructed3');