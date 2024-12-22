function logger(message)
disp(sprintf("%s: %s", datestr(now, 'HH:MM:SS.FFF AM'), message));
end