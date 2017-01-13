function [PDS ,c ,s]=joypress_finish(PDS ,c ,s)

% if rem(c.trinblk-1,c.trialsperblock)==0 && c.blockstartflag==0
%     if c.trialtype==3
%         if c.repeatblock==1 ;%&& c.fixvoilations<=2
%             c.blockno=c.blockno+1;c.blockstartflag=1;c.blocksetflag=0;
%             c.repeatblock=2;
%         elseif c.repeatblock==0
%             if c.fixvoilations<=2
%             c.blockno=c.blockno+1;c.blockstartflag=1;c.blocksetflag=0;
%             elseif c.fixvoilations>2 
%                 c.repeatblock=1;c.blockstartflag=1;c.blocksetflag=0;
%             end
%         end
%     else
%      c.blockno=c.blockno+1;c.blockstartflag=1;c.blocksetflag=0;
%     end
%     if c.repeatblock==2
%         c.repeatblock=0;
%     end
%     s.repeatblock=c.repeatblock;
% elseif rem(c.trinblk-1,c.trialsperblock)~=0
%       c.blockstartflag=0;  
% end

if rem(c.trinblk-1,c.trialsperblock)==0 && c.blockstartflag==0
    c.blockno=c.blockno+1;c.blockstartflag=1;c.blocksetflag=0;
elseif rem(c.trinblk-1,c.trialsperblock)~=0
      c.blockstartflag=0;  
end

    s.blockno=c.blockno;

%% save data
if c.blockno>1
%save data
    if rem(c.blockno-1,33)==0 && c.saved==0 % save data every 32 blocks(~ run in scanner)
    datename=datevec(date);
    datename1=num2str(datename(1)-2000);
    if datename(2)<10; datename2=strcat(num2str(0), num2str(datename(2)));
    else
        datename2=num2str(datename(2));
    end
    if datename(3)<10; datename3=strcat(num2str(0), num2str(datename(3)));
    else
        datename3=num2str(datename(3));
    end
    Datename=strcat(datename1,datename2,datename3);
    nfile=num2str(c.j);
    
    if c.preinjection==0 && c.postinjection==0
%     sfile=strcat('R', Datename, '_attn_blkdsgn','_', nfile);
    sfile=strcat('R', Datename, '_attn_blkdsgn','_', num2str(c.filesuffix));
    elseif c.preinjection==1 && c.postinjection==0
    sfile=strcat('R', Datename, '_attn_blkdsgn_preinj','_', nfile);
    elseif c.preinjection==0 && c.postinjection==1
    sfile=strcat('R', Datename, '_attn_blkdsgn_postinj','_', nfile);
    end
% put up blue screen before saving
%     Screen('FillRect', c.window,c.savecolor)
%     Screen('Flip', c.window);
% %     save 
% %     save(['Data/' sfile '.mat'],'PDS','c','s','-mat');
%     WaitSecs(30);
    Screen('FillRect', c.window,c.backcolor)
    Screen('Flip', c.window);
    
    c.filename=sfile;
    c.saved=1;
    elseif rem(c.blockno-1,33)~=0
    c.saved=0;
    end
% compute behav
    if rem(c.blockno-1,c.blocksperset)==0 && c.compute==0
    c.compute=1;
    elseif rem(c.blockno-1,c.blocksperset)~=0
        c.compute=0;
    end
end


% If the plotting-window is still open, plot into it, if it's not, open a
% % new window to plot into.
 if c.compute==1 
    if(ishghandle(1))
        set(0,'CurrentFigure',c.plotwin)
    else
        c.plotwin = figure('Position', [1200 100 1000 500]);
    end


%% --


[phr1, pcihr1] = binofit(sum(PDS.setno==c.setno & PDS.trialtype==1 & PDS.fixchangetrial==1 & PDS.state==4.1),sum(PDS.setno==c.setno & PDS.trialtype==1 & PDS.fixchangetrial==1 & (PDS.state==4.1 | PDS.state==3.4)),0.05);
[pfa1, pcifa1] = binofit(sum(PDS.setno==c.setno & PDS.trialtype==1 & PDS.state==3.3),sum(PDS.setno==c.setno & PDS.trialtype==1 & PDS.timebrokefix==-1 & PDS.timebrokejoy==-1),0.05);

y1=[phr1 pfa1];
%--

[phr2, pcihr2] = binofit(sum(PDS.setno==c.setno & PDS.trialtype==2 & PDS.fixchangetrial==1 & PDS.state==4.1),sum(PDS.setno==c.setno & PDS.trialtype==2 & PDS.fixchangetrial==1 & (PDS.state==4.1 | PDS.state==3.4)),0.05);
[pfa2, pcifa2] = binofit(sum(PDS.setno==c.setno & PDS.trialtype==2 &  PDS.state==5),sum(PDS.setno==c.setno & PDS.trialtype==2 & PDS.dirchangetrial>0 & (PDS.dirchangetime < PDS.fpchangetime+c.rewardwait) & (PDS.state==4.1 | PDS.state==3.4 | PDS.state==4.2 |PDS.state==5)),0.05);

y2=[phr2 pfa2];
%-

[phr3, pcihr3] = binofit(sum(PDS.setno==c.setno & PDS.trialtype==3 & PDS.dirchangetrial>0 & PDS.state==4.1),sum(PDS.setno==c.setno & PDS.trialtype==3  & PDS.dirchangetrial>0 & (PDS.state==4.1 | PDS.state==3.4)),0.05);
[pfa3, pcifa3] = binofit(sum(PDS.setno==c.setno & PDS.trialtype==3 & PDS.state==3.3),sum(PDS.setno==c.setno & PDS.trialtype==3 & PDS.timebrokefix==-1 & PDS.timebrokejoy==-1),0.05);

y3=[phr3 pfa3];
%--
[phr4, pcihr4] = binofit(sum(PDS.setno==c.setno & PDS.trialtype==4 & PDS.dirchangetrial>0 & PDS.state==4.1),sum(PDS.setno==c.setno & PDS.trialtype==4  & PDS.dirchangetrial>0 & (PDS.state==4.1 | PDS.state==3.4)),0.05);
[pfa4, pcifa4] = binofit(sum(PDS.setno==c.setno & PDS.trialtype==4 & PDS.state==3.3),sum(PDS.setno==c.setno & PDS.trialtype==4 & PDS.timebrokefix==-1 & PDS.timebrokejoy==-1),0.05);

y4=[phr4 pfa4];
%--
fb4=sum(PDS.setno==c.setno & PDS.trialtype==4 &  PDS.timebrokefix~=-1)/sum(PDS.setno==c.setno & PDS.trialtype==4);
if fb4==0
s.fixgoodblocks4=s.fixgoodblocks4+1;
end 

fb3=sum(PDS.setno==c.setno & PDS.trialtype==3 &  PDS.timebrokefix~=-1)/sum(PDS.setno==c.setno & PDS.trialtype==3);
if fb3==0
s.fixgoodblocks3=s.fixgoodblocks3+1;
end 

fb1=sum(PDS.setno==c.setno & PDS.trialtype==1 &  PDS.timebrokefix~=-1)/sum(PDS.setno==c.setno & PDS.trialtype==1);
if fb1==0
s.fixgoodblocks1=s.fixgoodblocks1+1;
end 

fb2=sum(PDS.setno==c.setno & PDS.trialtype==2 &  PDS.timebrokefix~=-1)/sum(PDS.setno==c.setno & PDS.trialtype==2);
if fb2==0
s.fixgoodblocks2=s.fixgoodblocks2+1;
end 

x=1:c.setno;
y=100.*[y1 y2 y3 y4 fb1 fb2 fb3 fb4];

c.cumy=[c.cumy; y];
if(ishghandle(1))
    set(0,'CurrentFigure',c.plotwin)
else
    c.plotwin = figure('Position', [1200 100 1000 500]);
end
if c.setno==1
c.h1=plot(x,c.cumy(1:c.setno,1),'-r','LineWidth',2);
hold on
c.h2=plot(x,c.cumy(1:c.setno,2),'-.r','LineWidth',2);
hold on
c.h3=plot(x,c.cumy(1:c.setno,3),'-b','LineWidth',2);
hold on
c.h4=plot(x,c.cumy(1:c.setno,4),'-.b','LineWidth',2);
hold on
c.h5=plot(x,c.cumy(1:c.setno,5),'-k','LineWidth',2);
hold on
c.h6=plot(x,c.cumy(1:c.setno,6),'-.k','LineWidth',2);
hold on;
c.h7=plot(x,c.cumy(1:c.setno,7),'-g','LineWidth',2);
hold on
c.h8=plot(x,c.cumy(1:c.setno,8),'-.g','LineWidth',2);
hold on;
c.h9=plot(x,c.cumy(1:c.setno,9),'-.c','LineWidth',1);
hold on;
c.h10=plot(x,c.cumy(1:c.setno,10),'-c','LineWidth',1);
hold on;
c.h11=plot(x,c.cumy(1:c.setno,11),'-.m','LineWidth',1);
hold on;
c.h12=plot(x,c.cumy(1:c.setno,12),'-m','LineWidth',1);
hold on;

xlabel('block no');
ylabel(' %');
% legend('hits1', 'ant.rel1', 'hits2', 'ant.rel2', 'hits3', 'ant.rel3', 'fixbreaks1', 'fixbreaks2', 'fixbreaks3');
ylim([-10 110]);
elseif c.setno>1
    set(c.h1,'XData',x,'YData',c.cumy(1:c.setno,1))
    set(c.h2,'XData',x,'YData',c.cumy(1:c.setno,2))
    set(c.h3,'XData',x,'YData',c.cumy(1:c.setno,3))
    set(c.h4,'XData',x,'YData',c.cumy(1:c.setno,4))
    set(c.h5,'XData',x,'YData',c.cumy(1:c.setno,5))
    set(c.h6,'XData',x,'YData',c.cumy(1:c.setno,6))
    set(c.h7,'XData',x,'YData',c.cumy(1:c.setno,7))
    set(c.h8,'XData',x,'YData',c.cumy(1:c.setno,8))
    set(c.h9,'XData',x,'YData',c.cumy(1:c.setno,9))
    set(c.h10,'XData',x,'YData',c.cumy(1:c.setno,10))
    set(c.h11,'XData',x,'YData',c.cumy(1:c.setno,11))
    set(c.h12,'XData',x,'YData',c.cumy(1:c.setno,12))

end

c.compute=2;
c.setno=c.setno+1;
s.setno=c.setno;

end

end