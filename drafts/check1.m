% mydata = exprnd(1,10000, 1);
% mean(mydata)
% hist(mydata);
% \\
% mycdata = mydata(mydata<2);

% mycdata = min(2, mydata);
censor = mydata>2;