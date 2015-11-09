function [indicesA, indicesB] = getConditionsReleventTimePoints(scanLenght, prt, conditions2classify, tmpFromOnset)
condindices = getCondIndices(prt, conditions2classify);
indicesA = condindices{1} + tmpFromOnset(1);
indicesA = indicesA(indicesA < scanLenght);  
indicesB = condindices{2} + tmpFromOnset(2);
indicesB = indicesB(indicesB < scanLenght); 
end

function condindices = getCondIndices(cond_all, cond_sub)
for i = 1:length(cond_sub)
    cond = cond_sub{i};
    % find cond in cond_all
    for j = 1:length(cond_all)
        if strcmp(cond,cond_all(j).ConditionName)
            condindices{i} = cond_all(j).OnOffsets(:,2);
            break
        end
    end
end
end
