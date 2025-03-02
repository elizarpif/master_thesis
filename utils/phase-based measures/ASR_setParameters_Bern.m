% IN this script different parameters are going to be set

fs = 512;

% Parameter of the filter [**]
ParamFilter.detrend = 1;        % Apply detrending before filtering [***]
ParamFilter.lorderp = 8;        % order of low-pass
ParamFilter.lcp = 40;           % low-pass cut-off freq [Hz]
ParamFilter.slp = 46.5;         % low band-stop [Hz]
ParamFilter.shp = 53.5;         % high band-stop [Hz]
ParamFilter.sorderp = 40;       % order band-stop

%[**] The data as provided on the page is sampled at 512 HZ and band-pass
% filtered between 0.5Hz and 150Hz. As described in the manuscript, we
% applied an additional low-pass Butterworth-filter with a cut-off frequency
% of 40Hz. Furthermore, we applied a stop-band filter between 46.5HZ and
% 53.5Hz to supress 50Hz line noise. Note however, that this stop-band
% filter has almost no effect, since the filter function the low-pass at 40Hz 
% already very small at 50Hz. So, the low-pass already supresses the line
% noise.
% Important note: this filtering is the first step of analysis, and the type of
% pre-processing should be adjusted to the specific type of data under
% analysis.