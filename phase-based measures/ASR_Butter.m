function xout = ASR_Butter(x,fs,ParamFilter)
% This source code forms part of the resources published along with
% Reference [1]. Please refer to http://www.dtic.upf.edu/~ralph/sc/index.html 
% for further specifications and conditions of use. 
% References 
% [1] Andrzejak RG, Schindler K and Rummel C, Phys. Rev. E 86, 046206, 2012

M = length(x);
Mdiv2 = M/2;

lc = ParamFilter.lcp*2*Mdiv2/fs;  % 40 Hz
sbl = ParamFilter.slp*2*Mdiv2/fs; % 46.5 Hz
sbh = ParamFilter.shp*2*Mdiv2/fs; % 53.5 Hz
lorder = ParamFilter.lorderp*2;   % Order low pass -> 8
sborder = ParamFilter.sorderp*2;  % Order band-stop -> 40
sb = round((sbl+sbh)/2);


frange = 1:Mdiv2;
faktor = (1./(1+(frange/lc).^lorder));
frange2a = 1:sb;
frange2b = sb+1:Mdiv2;
faktor2 = [(1./(1+(frange2a/sbl).^sborder)) (1./(1+(sbh./frange2b).^sborder))];
faktor3 = faktor.*faktor2;     


y = fft(x,M);
for k = 2:Mdiv2;
    y(k) = y(k) * faktor3(k);
    y(M-k+2) = y(M-k+2)*faktor3(k);        
end
y(Mdiv2+1) = (1./(1+((Mdiv2+1)/lc).^lorder));

xout = real(ifft(y,M));





