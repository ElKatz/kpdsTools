function [triallist1, triallist2, triallist3, triallist4, trialtype_values, trialtype_names]= trialcodes_AttnMot
%% Trial Types
trialtype_names = {'fpdim', 'stimchange', 'changeloc','no of trials', 'trialtype', 'stimcode'};
% fp dim:0-no change;1-change
% dir change:0-no change;1-CCW;2-CW
% changeloc: loc1 - RF loc; loc 2 - opp to RF loc
trialtype_values= [1            0             0              8             1    20001;   % baseline FP change trials 
                   0            0             0              4             1    20000;   % baseline FP no change trials   
%                  
                   1            1             1              6             2    21001;   % FA change trials (changeloc:1;dirdelta:1) 
                   1            1             2              6             2    21002;   % FA change trials (changeloc:2;dirdelta:1)
                   1            0             0             12             2    21000;   % FA change trials (no motion dir change)
                   1            2             1              6             2    21003;   % FA change trials (changeloc:1;dirdelta:2)
                   1            2             2              6             2    21004;   % FA change trials (changeloc:2;dirdelta:2) 
%                   
                   0            1             1              3             2    21005;   % FA no change trials (changeloc:1;dirdelta:1)
                   0            1             2              3             2    21006;   % FA no change trials (changeloc:2;dirdelta:1)
                   0            0             0              6             2    21009;   % FA no change trials (no motion dir change)
                   0            2             1              3             2    21007;   % FA no change trials (changeloc:1;dirdelta:2)
                   0            2             2              3             2    21008;   % FA no change trials (changeloc:2;dirdelta:2)      
%                   
                   0            1             1              5             3    23001;    % single patch change trials (changeloc:1;dirdelta:1)                  
                   0            1             2              5             3    23002;    % single patch change trials (changeloc:2;dirdelta:1)
                   0            0             1              5             3    23003;    % single patch no change trials (loc:1;no change) 
                   0            2             1              5             3    23006;    % single patch change trials (changeloc:1;dirdelta:2)                 
                   0            2             2              5             3    23007;    % single patch change trials (changeloc:2;dirdelta:2)
                   0            0             2              5             3    23008;    % single patch no change trials];(loc:2;no change)
%                   
                   0            1             1              9             4    22001;   % PA change trials (changeloc:1;dirdelta:1)
                   0            1             2              9             4    22002;   % PA change trials (changeloc:2;dirdelta:1)
                   0            0             0             18             4    22000;   % PA no change trials (no motion dir change)
                   0            2             1              9             4    22003;   % PA change trials (changeloc:1;dirdelta:2)
                   0            2             2              9             4    22004;   % PA change trials (changeloc:2;dirdelta:2)
                   ];

%% for trialtype 1 : baseline
triallist1=[];
for i=1:2 
    triallist1=[triallist1 i.*ones(1,trialtype_values(i,4))];
end
triallist1=Shuffle(triallist1);

%% for trialtype 2 : FA
triallist2=[];
for i=3:12 
    triallist2=[triallist2 i.*ones(1,trialtype_values(i,4))];
end
triallist2=Shuffle(triallist2);

%% for trialtype 3 : SPA
triallist3=[];
for i=13:18 
    triallist3=[triallist3 i.*ones(1,trialtype_values(i,4))];
end
triallist3=Shuffle(triallist3);

%% for trialtype 4 : PA
triallist4=[];
for i=19:23 
    triallist4=[triallist4 i.*ones(1,trialtype_values(i,4))];
end
triallist4=Shuffle(triallist4);




