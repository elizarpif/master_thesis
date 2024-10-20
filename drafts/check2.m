for i = 1:32
    if R_notch(i,1)>0.83
        a=2*i-1
        disp(channelNameArray(2*i-1:2*i))
    end
end