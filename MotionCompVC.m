clear
close all ;
%% Choose foreman image or not
image_foreman =  true ;% && false;

%% Reading the YUV file
if image_foreman
    vid = yuv_import_y('foreman_qcif.yuv',[176 144],50);
    evalInter('foreman');
else
    vid = yuv_import_y('mother-daughter_qcif.yuv',[176 144],50);
    evalInter('mother');
end

load('IntraStats.mat')
load('InterStats.mat')

%% Calculating motion vectors and their statistics
[~,vidMotion] = videoMC(vid);
motionStats = motionInfo(vidMotion);

%% Store Variables
range = 3:6;
rateList = zeros(size(range,1),1) ;
psnrList = zeros(size(range,1),1) ;
vidReconstructed = cell(size(range, 1),1);

j=1 ;

for i=range
    %% Uniform Quantizer
    stepSize = 2^i;
    
    %% Entropy Calculation
    blockStatsIntra = intraStats{j};
    blockStatsInter = interStats{j};
    
    %% Rate Calculation
    framesPerSecond = 30 ;
    c = 0.2;
    [vidReconstructed{j},totalBits] = condRep2(vid,vidMotion,stepSize,blockStatsIntra,blockStatsInter,motionStats,c);
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
rates4 = rateList;
psnr4 = psnrList;
vidReconstructed4 = vidReconstructed;
save('ex4.mat','rates4','psnr4','vidReconstructed4');