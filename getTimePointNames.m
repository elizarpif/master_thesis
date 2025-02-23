function timePointNames = getTimePointNames(intervalJump, lengthData, Fs)
    timePoints = (intervalJump:intervalJump:lengthData) / Fs;
    
    if lengthData/Fs ~= timePoints(end)
        timePoints = [timePoints lengthData/Fs];
    end

    timePointNames = string(timePoints);
end