function evalInter(name)
if strcmp(name,'foreman')
    name = 'foreman_qcif.yuv';
elseif strcmp(name,'mother')
    name = 'mother-daughter_qcif.yuv';
else
    return
end
vid = yuv_import_y(name,[176 144],50);


%% Calculating motion compensated
[vidMC,~] = videoMC(vid);
vidMCDCT =videoDct(vidMC);
%% Store Variables
range = 3:6;
interStats = cell(size(range,1),1);
j=1 ;
for i=range
    %% Uniform Quantizer
    stepsize = 2^i ;
    vidMCDCTQ = videoQuantizer(vidMCDCT,stepsize) ;
    interStats{j} = dctInfo(vidMCDCTQ,stepsize);
    %% Counter
    j=j+1 ;
end
save('InterStats.mat', 'interStats')
