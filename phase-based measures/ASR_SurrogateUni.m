function [xout] = ASR_SurrogateUni(x,ParamSurro)
% This source code forms part of the resources published along with
% Reference [1]. Please refer to http://www.dtic.upf.edu/~ralph/sc/index.html 
% for further specifications and conditions of use. 

% For a reference that describe this particular algorithm please refer to
% [2].


% References 
% [1] Andrzejak RG, Schindler K and Rummel C, Phys. Rev. E 86, 046206, 2012
% [2] Schreiber T and Schmitz A, Phys. Rev. Lett. 77, 635, 1996

M=length(x);
%Store sorted amplitude values 
xs= sort(x);
%Store amplitudes of Fourier coefficients 
pwx = abs(fft(x,M));
%Start with random shuffle of time series
xsur = x(randperm(M)); 
for istep = 1:ParamSurro.MaxIter
    fftsurx = pwx.*exp(1i*angle(fft(xsur,M)));
    xoutb = real(ifft(fftsurx,M));          
    [~, P] = sort(xoutb);
    xsur(P) = xs; 
end
if ParamSurro.type ==1 
  xout = xsur;
else
 xout = xoutb;    
end

