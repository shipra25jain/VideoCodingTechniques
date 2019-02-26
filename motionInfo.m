function statistics = motionInfo(vidMotion)
arr = [] ;
% Iteration over frames
for i=2:size(vidMotion,1)
    arr = [arr getBlockSequence(vidMotion{i})] ;
end
statistics = cell(size(arr,1),1) ;
% Iterate over every row
for i = 1:size(arr,1)
    sig = arr(i,:);
    [value,~,ic] = unique(sig);
    count = accumarray(ic,1);
    prob = count/sum(count);
    statistics{i} = [value',prob,-log2(prob)];
end
motionStats = statistics; 
% Calculate mean over all 256 coeffiecient in the blocks
save('MotionStats.mat', 'motionStats')
end

% s = 16 for project
function [arr] = getBlockSequence(motionFrame)
    row = size(motionFrame,1) ;
    col = size(motionFrame,2) ;
    arr = [];
    for i = 1:row
        for j = 1:col
            block = motionFrame{i,j};
            arr = [arr block(:)];
        end
    end
end