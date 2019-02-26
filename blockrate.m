function R_block = blockrate(block,blockStats)
    vec = block(:);
    R_block = 0;
    for k = 1:length(vec)
        coeffStats = blockStats{k};
        coeff = vec(k);
        [symIdx,~] = find(coeffStats(:,1)==coeff);
        if isempty(symIdx)
            symLength = 8; %bit
            disp('Error')
        else
            symLength = coeffStats(symIdx,3);
        end
        R_block = R_block + symLength;
    end
end