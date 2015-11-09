function alignVTCandICMaps_NR(vtc, ica)

res(1,:) = [vtc.XStart,ica.XStart];
res(2,:) = [vtc.XEnd, ica.XEnd];
res(3,:) = [vtc.XStart, ica.XStart];
res(4,:) = [vtc.YEnd, ica.YEnd];
res(5,:) = [vtc.XStart, ica.XStart];
res(6,:) = [vtc.ZEnd, ica.ZEnd];

diffs = res(:,1) == res(:,2);
if sum(diffs)
    fixin = find(~diffs);
    for i = fixin
        switch i
            case 1 3 5
                sstart = max(res(i,:));
                ind2start = abs(diff(res(i,:));
                
                vtc_data = vtc.VTCData(:,; 
            case 2 4 6
                eend = min(res(i));
                
        end
    

end