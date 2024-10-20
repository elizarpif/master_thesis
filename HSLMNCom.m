function H = HSLMNCom(Datarec,m,tau,krec,W)
%
% Calculates the following interdependence measures:
%
% H, S:   J. Arnhold, K. Lehnertz, P. Grassberger, and C. E. Elger, Physica D 134, 419, 1999.
% N:      R. Quian Quiroga, A. Kraskov, T. Kreuz, and P. Grassberger, Phys. Rev. E 65, 041903, 2002.  
% M:      defined independently in (A) 
% R. G. Andrzejak, A. Kraskov, H. Stögbauer, F. Mormann, T. Kreuz, Phys. Rev. E 68, 066202, 2003.
%         and in
% H. Kantz and T. Schreiber, Nonlinear Time Series Analysis Cambridge University Press, Cambridge, U.K., Second edition 2003, Chapter 14
% D. Chicharro and R. G. Andrzejak Reliable detection of directional couplings using rank statistics. Physical Review E, 80, 026217, 2009
% 
%
% 
% The data must be given in Datarec with dimension (N*,2). N* is the length
% of the original time series. The first component should contain X, the
% second should contain Y. 
%
% The parameter m is the embedding dimension and tau is the time
% delay used for the delay reoncstruction. 
%
% The parameter krec is an array of numbers of nearest neighbors k. 
% The algorithm can return results for a whole range of k in just one run. 
%
% The parameter W is the Theiler correction. W temporally nearest 
% neighbors will be excluded from the distance matrix. For W = 0, only the
% diagonal will be excluded. 
%
% The results are output in H organized in an (5,2,length(krec)) array.
% The first axis comprises the different measures [H, L, S, M, N]
% The second axis is for the directions. IMPORTANT it returns [(Y|X) (X|Y)]
% The third axis is for the different numbers of nearest neighbors [krec]


% Algorithm Start
% Determine the number of data points and substract the embedding window.

N = size(Datarec);
N = N(1);
embwin = (m-1)*tau;
Neff = N -embwin;


% Allocate matrices.
Hdistances1 =zeros(Neff,Neff);
Hdistances2 =zeros(Neff,Neff);
Hranks1 = zeros(Neff,Neff);
Hranks2 = zeros(Neff,Neff);

% Determine distance matrices.
for counter1 = embwin+1:embwin+tau
    for counter2 = counter1+1+W:N
        distA = 0;
        distB = 0;
        for index = -embwin:tau:0;
            distA = distA+(Datarec(counter1+index,1)-Datarec(counter2+index,1))^2; % X
            distB = distB+(Datarec(counter1+index,2)-Datarec(counter2+index,2))^2; % Y
        end
        Hdistances1(counter1-embwin,counter2-embwin)=distA;
        Hdistances2(counter1-embwin,counter2-embwin)=distB;
    end
end
for counter1 = embwin+1+tau:N
    for counter2 = counter1+1+W:N
        Hdistances1(counter1-embwin,counter2-embwin)= Hdistances1(counter1-embwin-tau,counter2-embwin-tau)-(Datarec(counter1-embwin-tau,1)-Datarec(counter2-embwin-tau,1))^2+(Datarec(counter1,1)-Datarec(counter2,1))^2;
        Hdistances2(counter1-embwin,counter2-embwin)= Hdistances2(counter1-embwin-tau,counter2-embwin-tau)-(Datarec(counter1-embwin-tau,2)-Datarec(counter2-embwin-tau,2))^2+(Datarec(counter1,2)-Datarec(counter2,2))^2;
    end
end

% Symmetrize the distance matrices.

Hdistances1 = Hdistances1+Hdistances1';
Hdistances2 = Hdistances2+Hdistances2';

% Calculate effective number of distances
% Ncorrected(counter) is the number of distances contained in the distance matrix' row/colum
% with index counter. Here, the Theiler correction W has to be taken into
% account.

Ncorrected = zeros(1,Neff);
Ncorrected(1:Neff) = Neff-(W*2+1);
for counter = 1:W
    Ncorrected(counter) = Neff-W-(counter);
    Ncorrected(Neff-counter+1) = Neff-W-(counter);
end;

Hsums1 = sum(Hdistances1)./Ncorrected;
Hsums2 = sum(Hdistances2)./Ncorrected;

% Overwrite zeros that were skipped due to the Theiler correction with an
% arbitrary high number. IMPORTANT: This number must be higher than the
% highest distance expected in the distance matrix.

highnumber = 1e99;
Hdistances1(Hdistances1==0)=highnumber;
Hdistances2(Hdistances2==0)=highnumber;

% Calculate the matrices of ranks.
% Note that were here use the same way to determine the ranks as Matlab
% does for example in the function ranksum.m

[temparr1 Hindexes1] = sort(Hdistances1);
[temparr1 Hindexes2] = sort(Hdistances2);
N1 = 1:Neff;
for s = 1:Neff
    Hranks1(Hindexes1(:,s),s) = N1;
    Hranks2(Hindexes2(:,s),s) = N1;
end


Hj= zeros(5,2,Neff,length(krec));

% Calculate the actual measures.

kc = 0;
for k = krec
    kc = kc +1;
    for j = 1:Neff
        RkY = sum(Hdistances2(Hindexes2(1:k,j),j))/k;                       
        RkX = sum(Hdistances1(Hindexes1(1:k,j),j))/k;                       
        RcondYX = sum(Hdistances2(Hindexes1(1:k,j),j))/k;                   
        RcondXY = sum(Hdistances1(Hindexes2(1:k,j),j))/k;                   

        Hj(1,1,j,kc)= log(Hsums2(j)/RcondYX);                               
        Hj(1,2,j,kc)= log(Hsums1(j)/RcondXY);                               
        %RNY/Rcond(Y|X)=>H(Y|X)
        %RNX/Rcond(X|Y)=>H(X|Y)
        
        Hj(2,1,j,kc) = ((Ncorrected(j)+1)/2-sum(Hranks2(Hindexes1(1:k,j),j))/k)/((Ncorrected(j)+1)/2-(k+1)/2);        
        Hj(2,2,j,kc) = ((Ncorrected(j)+1)/2-sum(Hranks1(Hindexes2(1:k,j),j))/k)/((Ncorrected(j)+1)/2-(k+1)/2);
        % (GN-G(Y|X))/(GN-Gk) => L(Y|X)
        % (GN-G(X|Y))/(GN-Gk) => L(X|Y)
                
        Hj(3,1,j,kc) = RkY/RcondYX;                                         
        Hj(3,2,j,kc) = RkX/RcondXY;                                          
        %RkY/Rcond(Y|X)=>S(Y|X)
        %Rk1/Rcond(X|Y)=>S(X|Y)
        
        Hj(4,1,j,kc) = (Hsums2(j)-RcondYX)/(Hsums2(j)-RkY);
        Hj(4,2,j,kc) = (Hsums1(j)-RcondXY)/(Hsums1(j)-RkX);
        %(RNY-Rcond(Y|X))/(RNY-RkY)=>M(Y|X)
        %(RNX-Rcond(X|Y))/(RNX-RkX)=>M(X|Y)
        
        Hj(5,1,j,kc) = (Hsums2(j)-RcondYX)/(Hsums2(j));
        Hj(5,2,j,kc) = (Hsums1(j)-RcondXY)/(Hsums1(j));

        %(RNY-Rcond(Y|X))/(RNY)=>N(Y|X)
        %(RNX-Rcond(X|Y))/(RNX)=>N(X|Y)

        
    end
end

% Finally, take the mean across all reference points
H = squeeze(mean(Hj,3));
