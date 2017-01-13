function [PDS ,c ,s] = plot_prepost_inj(PDS ,c ,s)
% load pre injection data


filename=strcat('R', datestr(date,'yymmdd'), '_attn_blkdsgn_preinj');    

data_pre=load(['/Users/klab/Documents/snap/physiology/attnblkdsgn/Data/' filename '.mat']);

figure('Position', [20 900 1175 715]);
% plot pre inj results
plot_behavior(data_pre.PDS,1,c)

% plot post inj results
plot_behavior(PDS,2,c)
%plot
function plot_behavior(datastruct1,session,c)

%-- B block perf
[phr1, pcihr1] = binofit(sum(datastruct1.trialtype==1 & datastruct1.fixchangetrial==1 & datastruct1.state==4.1),sum(datastruct1.trialtype==1 & datastruct1.fixchangetrial==1 & (datastruct1.state==4.1 | datastruct1.state==3.4)),0.05);
[pfa1, pcifa1] = binofit(sum(datastruct1.trialtype==1 & datastruct1.state==3.3),sum(datastruct1.trialtype==1 & datastruct1.timebrokefix==-1 & datastruct1.timebrokejoy==-1),0.05);

%FA blocks hitrate
[phr2, pcihr2] = binofit(sum(datastruct1.trialtype==2 & datastruct1.fixchangetrial==1 & datastruct1.state==4.1),sum(datastruct1.trialtype==2 & datastruct1.fixchangetrial==1 & (datastruct1.state==4.1 | datastruct1.state==3.4)),0.05);

% PA block antrels
[pfa3, pcifa3] = binofit(sum(datastruct1.trialtype==3 & datastruct1.state==3.3),sum(datastruct1.trialtype==3 & datastruct1.timebrokefix==-1 & datastruct1.timebrokejoy==-1),0.05);

%% polar plot for diff locations

locs=[c.loc1deg c.loc2deg];
for locno=1:size(locs,2)
% PA hits   
[phr3{locno}, pcihr3{locno}] = binofit(sum(datastruct1.changeloc==locs(locno) & datastruct1.trialtype==3 & datastruct1.dirchangetrial>0 & datastruct1.state==4.1),sum(datastruct1.changeloc==locs(locno) & datastruct1.trialtype==3  & datastruct1.dirchangetrial>0 & (datastruct1.state==4.1 | datastruct1.state==3.4)),0.05);

% FA false alarms
[pfa2{locno}, pcifa2{locno}] = binofit(sum(datastruct1.changeloc==locs(locno) & datastruct1.trialtype==2 &  datastruct1.state==5),sum(datastruct1.changeloc==locs(locno) & datastruct1.trialtype==2 & datastruct1.dirchangetrial>0 & (datastruct1.dirchangetime < datastruct1.fpchangetime+c.rewardwait) & (datastruct1.state==4.1 | datastruct1.state==3.4 | datastruct1.state==4.2 |datastruct1.state==5)),0.05);
end

%%
x=[1 2 3 4 5 6 7];
y=[phr1 phr2 pfa2{1} pfa2{2} phr3{1} phr3{2} pfa3];
yl=[pcihr1(1) pcihr2(1) pcifa2{1}(1) pcifa2{2}(1) pcihr3{1}(1) pcihr3{2}(1) pcifa3(1)];
yh=[pcihr1(2) pcihr2(2) pcifa2{1}(2) pcifa2{2}(2) pcihr3{1}(2) pcihr3{2}(2) pcifa3(2)];
yl=y-yl;
yh=yh-y;
subplot(1,2,1)
hold on
if session==1
errorbar(x(1:4),y(1:4),yl(1:4),yh(1:4),'ks','MarkerEdgeColor', 'g', 'MarkerFaceColor' ,'g', 'MarkerSize',6);
else
errorbar(x(1:4),y(1:4),yl(1:4),yh(1:4),'bs','MarkerEdgeColor', 'b', 'MarkerFaceColor' ,'b', 'MarkerSize',6);    
end
legend('pre', 'post');
 set(gca,'FontSize',12,'TickDir','out')
set(gca,'xTicklabel',{'', 'HR B', 'HR FA', ['fas FA Loc:' num2str(locs(1))], ['fas FA Loc:' num2str(locs(2))],''})
ylabel('%','FontSize',16,'FontWeight','bold')
xlim([0 5]);ylim([0 1]);
title('B and FA blocks performance');

subplot(1,2,2)
hold on
if session==1
errorbar([0.5 1 1.5],y(5:7),yl(5:7),yh(5:7),'ks','MarkerEdgeColor', 'g', 'MarkerFaceColor' ,'g', 'MarkerSize',6);
else
errorbar([0.5 1 1.5],y(5:7),yl(5:7),yh(5:7),'bs','MarkerEdgeColor', 'b', 'MarkerFaceColor' ,'b', 'MarkerSize',6);    
end
legend('pre', 'post');
 set(gca,'FontSize',12,'TickDir','out')
set(gca,'xTicklabel',{'', ['HR PA Loc:' num2str(locs(1))], ['HR PA Loc:' num2str(locs(2))],'fas PA', ''})
ylabel('%','FontSize',16,'FontWeight','bold')
xlim([0 2]);ylim([0 1]);
title('PA blocks performance');

end
end