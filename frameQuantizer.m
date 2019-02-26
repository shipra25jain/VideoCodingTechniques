function [out] = frameQuantizer(input,stepsize)
    out = stepsize*floor(input/stepsize + 0.5);
end