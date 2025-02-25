function timePointNames = getTimePointNames(intervalJump, lengthData, Fs)
    timePoints = (intervalJump:intervalJump:lengthData) / Fs;
    
    % % At first I included the last interval, but now not, because it is
    % % shorter than 20s 
    % if lengthData/Fs ~= timePoints(end)
    %     timePoints = [timePoints lengthData/Fs];
    % end

    timePointNames = string(timePoints);
end