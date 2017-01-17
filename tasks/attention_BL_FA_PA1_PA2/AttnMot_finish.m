function [PDS ,c ,s]=AttnMot_finish(PDS ,c ,s)
%% save data
if mod(c.j,500) == 1 % save data
    nfile=num2str(c.j);
    sfile=[c.output_prefix '_' datestr(date,'yymmdd') '_' num2str(c.filesuffix) '_' nfile];
    c.filename=sfile;
    save(['Data/' sfile '.mat'],'PDS','c','s','-mat');
end
%% update status values
s.NumRewards = c.NumRewards;
s.fixbreaks = c.fixbreaks;
s.antrels = c.antrels;
s.blockno = c.blockno;
s.setno = c.setno;
%% plot data
% If the plotting-window is still open, plot into it, if it's not, open a
% % new window to plot into.
if c.updateplot==1 
    if(ishghandle(1))
        set(0,'CurrentFigure',c.plotwin)
    else
        c.plotwin = figure('Position', [1400 100 1000 500]);
    end
setdone=c.setno-1;
%% --
[phr1, pcihr1] = binofit(sum(PDS.setno==setdone & PDS.trialtype==1 & PDS.fixchangetrial==1 & PDS.state==4.1),sum(PDS.setno==setdone & PDS.trialtype==1 & PDS.fixchangetrial==1 & (PDS.state==4.1 | PDS.state==3.4)),0.05);
[pfa1, pcifa1] = binofit(sum(PDS.setno==setdone & PDS.trialtype==1 & PDS.fixchangetrial==0 & PDS.state==3.5),sum(PDS.setno==setdone & PDS.trialtype==1 & PDS.fixchangetrial==0 & (PDS.state==4.2 | PDS.state==3.5)),0.05);

y1=[phr1 pfa1];
%--

[phr2, pcihr2] = binofit(sum(PDS.setno==setdone & PDS.trialtype==2 & PDS.fixchangetrial==1 & PDS.state==4.1),sum(PDS.setno==setdone & PDS.trialtype==2 & PDS.fixchangetrial==1 & (PDS.state==4.1 | PDS.state==3.4)),0.05);
[pfa2, pcifa2] = binofit(sum(PDS.setno==setdone & PDS.trialtype==2 &  PDS.state==5),sum(PDS.setno==setdone & PDS.trialtype==2 & PDS.stimchangetrial>0 & (PDS.stimchangetime < PDS.fpchangetime+c.rewardwait) & (PDS.state==4.1 | PDS.state==3.4 | PDS.state==4.2 |PDS.state==5)),0.05);

y2=[phr2 pfa2];
%-

[phr3, pcihr3] = binofit(sum(PDS.setno==setdone & PDS.trialtype==3 & PDS.stimchangetrial>0 & PDS.state==4.1),sum(PDS.setno==setdone & PDS.trialtype==3  & PDS.stimchangetrial>0 & (PDS.state==4.1 | PDS.state==3.4)),0.05);
[pfa3, pcifa3] = binofit(sum(PDS.setno==setdone & PDS.trialtype==3 & PDS.stimchangetrial==0 & PDS.state==3.5),sum(PDS.setno==setdone & PDS.trialtype==3 & PDS.stimchangetrial==0 & (PDS.state==4.2 | PDS.state==3.5)),0.05);

y3=[phr3 pfa3];
%--
[phr4, pcihr4] = binofit(sum(PDS.setno==setdone & PDS.trialtype==4 & PDS.stimchangetrial>0 & PDS.state==4.1),sum(PDS.setno==setdone & PDS.trialtype==4  & PDS.stimchangetrial>0 & (PDS.state==4.1 | PDS.state==3.4)),0.05);
[pfa4, pcifa4] = binofit(sum(PDS.setno==setdone & PDS.trialtype==4 & PDS.stimchangetrial==0 & PDS.state==3.5),sum(PDS.setno==setdone & PDS.trialtype==4 & PDS.stimchangetrial==0 & (PDS.state==4.2 | PDS.state==3.5)),0.05);

y4=[phr4 pfa4];
%%
x=1:setdone;
y=100.*[y1 y2 y3 y4];

c.cumy=[c.cumy; y];
if(ishghandle(1))
    set(0,'CurrentFigure',c.plotwin)
else
    c.plotwin = figure('Position', [1200 100 1000 500]);
end
if setdone==1
c.h1=plot(x,c.cumy(1:setdone,1),'-r','LineWidth',2);
hold on
c.h2=plot(x,c.cumy(1:setdone,2),'-.r','LineWidth',2);
hold on
c.h3=plot(x,c.cumy(1:setdone,3),'-b','LineWidth',2);
hold on
c.h4=plot(x,c.cumy(1:setdone,4),'-.b','LineWidth',2);
hold on
c.h5=plot(x,c.cumy(1:setdone,5),'-k','LineWidth',2);
hold on
c.h6=plot(x,c.cumy(1:setdone,6),'-.k','LineWidth',2);
hold on;
c.h7=plot(x,c.cumy(1:setdone,7),'-g','LineWidth',2);
hold on
c.h8=plot(x,c.cumy(1:setdone,8),'-.g','LineWidth',2);
hold on;
xlabel('set no');
ylabel(' %');
ylim([-10 110]);
elseif setdone>1
    set(c.h1,'XData',x,'YData',c.cumy(1:setdone,1))
    set(c.h2,'XData',x,'YData',c.cumy(1:setdone,2))
    set(c.h3,'XData',x,'YData',c.cumy(1:setdone,3))
    set(c.h4,'XData',x,'YData',c.cumy(1:setdone,4))
    set(c.h5,'XData',x,'YData',c.cumy(1:setdone,5))
    set(c.h6,'XData',x,'YData',c.cumy(1:setdone,6))
    set(c.h7,'XData',x,'YData',c.cumy(1:setdone,7))
    set(c.h8,'XData',x,'YData',c.cumy(1:setdone,8))
end

c.updateplot=0;
end

end