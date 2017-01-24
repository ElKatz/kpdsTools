function plotdata_allruns(date)
B=[];FA=[];PA=[];
files=dir(['/Users/klab/Documents/snap/physiology/attnblkdsgn/Data/R' num2str(date) '_attn_blkdsgn_*']);
total_files=size(files,1);
for fileno=1:total_files
%     data=load(['R' num2str(date) '_attn_blkdsgn_' num2str(fileno) '.mat']);
      data=load(files(fileno).name);

    [B_tmp, FA_tmp, PA_tmp]=get_behavparams(data);
    B=[B B_tmp];
    FA=[FA FA_tmp];
    PA=[PA PA_tmp];

end
figure();hold on;
x=[1 2];
[phit pcihit]=binofit(sum(B(1,:)),sum(B(2,:)));
[pfa pcifa]=binofit(sum(B(3,:)),sum(B(4,:)));
y=[phit pfa];
yl=[pcihit(1) pcifa(1)];
yh=[pcihit(2) pcifa(2)];
yl=y-yl;yh=yh-y;
subplot(2,4,1),errorbar(x,y,yl,yh,'ks','MarkerFaceColor','k','MarkerSize',6);
xlim([0 3]);ylim([0 1]);
set(gca,'FontSize',10);
set(gca,'xTicklabel',{'','Hits', 'Fas',''});
ylabel('%','FontSize',12);
title('B blocks Perf');

[phit pcihit]=binofit(sum(FA(1,:)),sum(FA(2,:)));
[pfa pcifa]=binofit(sum(FA(3,:)),sum(FA(4,:)));
y=[phit pfa];
yl=[pcihit(1) pcifa(1)];
yh=[pcihit(2) pcifa(2)];
yl=y-yl;yh=yh-y;
subplot(2,4,2),errorbar(x,y,yl,yh,'ks','MarkerFaceColor','k','MarkerSize',6);
xlim([0 3]);ylim([0 1]);
set(gca,'FontSize',10);
set(gca,'xTicklabel',{'','Hits', 'Fas',''});
ylabel('%','FontSize',12);
title('FA blocks Perf');

x=[1 2 3 4];
[phitL1 pcihitL1]=binofit(sum(PA(1,:)),sum(PA(2,:)));
[phitL2 pcihitL2]=binofit(sum(PA(3,:)),sum(PA(4,:)));
[phit pcihit]=binofit(sum(PA(5,:)),sum(PA(6,:)));
[pfa pcifa]=binofit(sum(PA(7,:)),sum(PA(8,:)));
y=[phitL1 phitL2 phit pfa];
yl=[pcihitL1(1) pcihitL2(1) pcihit(1) pcifa(1)];
yh=[pcihitL1(2) pcihitL2(2) pcihit(2) pcifa(2)];
yl=y-yl;yh=yh-y;
subplot(2,4,3:4),errorbar(x,y,yl,yh,'ks','MarkerFaceColor','k','MarkerSize',6);
xlim([0 5]);ylim([0 1]);
set(gca,'FontSize',10);
set(gca,'xTicklabel',{'','Hits:L1','Hits:L2','Hits', 'Fas',''});
ylabel('%','FontSize',12);
title('PA blocks Perf');

subplot(2,4,5:8),plot(B(1,:)./B(2,:),'*r');
hold on;
plot(FA(1,:)./FA(2,:),'*b');
plot(PA(1,:)./PA(2,:),'*k');
set(gca,'FontSize',10);
xlabel('run no');
ylabel('%','FontSize',12);
ylim([0 1]);
legend('B','FA','PA','Location','EastOutside');
end

function [B_params, FA_params, PA_params]=get_behavparams(data)
%% polar plot for diff locations
locs=[data.c.loc1deg data.c.loc2deg];

hits_loc1=sum(data.PDS.changeloc==locs(1) & data.PDS.trialtype==3 & data.PDS.dirchangetrial>0 & data.PDS.state==4.1);
changetrials_loc1=sum(data.PDS.changeloc==locs(1) & data.PDS.trialtype==3 & data.PDS.dirchangetrial>0 & (data.PDS.state==4.1 | data.PDS.state==3.4));

hits_loc2=sum(data.PDS.changeloc==locs(2) & data.PDS.trialtype==3 & data.PDS.dirchangetrial>0 & data.PDS.state==4.1);
changetrials_loc2=sum(data.PDS.changeloc==locs(2) & data.PDS.trialtype==3 & data.PDS.dirchangetrial>0 & (data.PDS.state==4.1 | data.PDS.state==3.4));


%%
%--
hits1=sum(data.PDS.trialtype==1 & data.PDS.fixchangetrial==1 & data.PDS.state==4.1);
changetrials1=sum(data.PDS.trialtype==1 & data.PDS.fixchangetrial==1 & (data.PDS.state==4.1 | data.PDS.state==3.4));
antrels1=sum(data.PDS.trialtype==1 & data.PDS.state==3.3);
totaltrials1=sum(data.PDS.trialtype==1 & data.PDS.timebrokefix==-1 & data.PDS.timebrokejoy==-1);

%--
hits2=sum(data.PDS.trialtype==2 & data.PDS.fixchangetrial==1 & data.PDS.state==4.1);
changetrials2=sum(data.PDS.trialtype==2 & data.PDS.fixchangetrial==1 & (data.PDS.state==4.1 | data.PDS.state==3.4));
fas2=sum(data.PDS.trialtype==2 &  data.PDS.state==5);
totalfoilchangetrials2=sum(data.PDS.trialtype==2 & data.PDS.dirchangetrial>0 & (data.PDS.dirchangetime < data.PDS.fpchangetime+data.c.rewardwait) & (data.PDS.state==4.1 | data.PDS.state==3.4 | data.PDS.state==4.2 |data.PDS.state==5));

%--

hits3=sum(data.PDS.trialtype==3 & data.PDS.dirchangetrial>0 & data.PDS.state==4.1);
changetrials3=sum(data.PDS.trialtype==3 & data.PDS.dirchangetrial>0 & (data.PDS.state==4.1 | data.PDS.state==3.4));
antrels3=sum(data.PDS.trialtype==3 & data.PDS.state==3.3);
totaltrials3=sum(data.PDS.trialtype==3 & data.PDS.timebrokefix==-1 & data.PDS.timebrokejoy==-1);

B_params=[hits1;changetrials1;antrels1;totaltrials1];
FA_params=[hits2;changetrials2;fas2;totalfoilchangetrials2];
PA_params=[hits_loc1;changetrials_loc1;hits_loc2;changetrials_loc2;hits3;changetrials3;antrels3;totaltrials3];


end