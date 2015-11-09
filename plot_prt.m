function plot_prt(prt, limits)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(prt)
    line([prt(i) prt(i)], [limits(1) limits(2)]);
end

end

