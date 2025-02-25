function Data=ASR_Filter(Data, fs, ParamFilter,L)
% This source code forms part of the resources published along with
% Reference [1]. Please refer to http://www.dtic.upf.edu/~ralph/sc/index.html
% for further specifications and conditions of use.
% References
% [1] Andrzejak RG, Schindler K and Rummel C, Phys. Rev. E 86, 046206, 2012
% Input:
%        - L: if we want to apply low pass filtering (L=1) or not (L=0)
D = size(Data,1);
for kkk = 1:D
    if ParamFilter.detrend
        Data(kkk,:) = detrend(Data(kkk,:));
    end
    
    if L==1
        Data(kkk,:) = ASR_Butter(Data(kkk,:),fs,ParamFilter); % with LPF
    else
        Data(kkk,:) = ASR_Butter_stop(Data(kkk,:),fs,ParamFilter); %without LPF
    end
    
    
end
