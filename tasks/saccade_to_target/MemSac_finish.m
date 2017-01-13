function [PDS ,c ,s] = MemSac_finish(PDS ,c ,s)


if s.TrialNumber >= c.finish
    % if so, stop running by setting flag to 0
    c.runflag = 0;
    ShowCursor
end

%% Read continuously sampled Eye and Joystick data

Datapixx('RegWrRd');                    % Update registers for GetAdcStatus
status = Datapixx('GetAdcStatus');
nReadSpls = status.newBufferFrames;      % How many Spls can we read?
[EyeJoy, EyeJoyts] = Datapixx('ReadAdcBuffer', nReadSpls, -1);
Datapixx('StopAdcSchedule');
% eye position
PDS.EyeXYZ{c.j-1} = EyeJoy(1:3,:);
PDS.adcts{c.j-1} = EyeJoyts;

%% saccade velocity
if PDS.timereward(s.TrialNumber) ~= -1 && c.mapeyevelocity==1
    ev_h = smoothdiff(-4*EyeJoy(1,floor(PDS.timefpaq(s.TrialNumber)*1000):floor(PDS.timetpaq(s.TrialNumber)*1000)+15));
    ev_v = smoothdiff(-4*EyeJoy(2,floor(PDS.timefpaq(s.TrialNumber)*1000):floor(PDS.timetpaq(s.TrialNumber)*1000)+15));
    ev_r = sqrt(ev_h.^2 + ev_v.^2);
    
    ind = sqrt((c.A-s.targXY(1)).^2 + (c.B-s.targXY(2)).^2) < 2;
%     ind = sqrt((c.X-abs(s.targXY(1))).^2 + (c.Y-s.targXY(2)).^2) < 2;
    
    if any(ind) && max(ev_r) < 1200
        chev =  max(ev_r) - median(c.EV(ind));
        s.X = [s.X; s.targXY(1)];
        s.Y = [s.Y; s.targXY(2)];
        s.sacV = [s.sacV; max(ev_r)];
        s.chV = [s.chV; chev];
        s.sact = [s.sact; (PDS.datapixxtime(s.TrialNumber)-PDS.datapixxtime(1))/60];
        
        if size(s.chV,1) >= 3 && size(unique(s.X),1) >= 3
            F = TriScatteredInterp(s.X,s.Y,s.chV);
            V = F(c.gridX,c.gridY);
            figure(2);
            pcolor(c.gridX,c.gridY,V);
            shading interp
            colorbar('East')
            caxis([-300 300])
            hold on
            plot(s.X,s.Y,'o','markeredgecolor','k','markerfacecolor','k','markersize',4)
            plot(0,0,'+','markeredgecolor','k','markerfacecolor','k','markersize',14)
            
            xlim([-30 30])
            ylim([-15 15])
            xlabel('X degree','FontSize',18)
            ylabel('Y degree','FontSize',18)
            grid on
            text(-13,14,'Deg/Sec','FontSize',18)
            title('Difference in Peak Saccade Velocity','FontSize',18)
            hold off
            warning('OFF')
        end
    end
end

%
ind=[];
if c.showsparks && ~isempty(s.X)
    ind = sqrt((s.targXY(1)-s.X).^2 + (s.targXY(2)-s.Y).^2) < 1;
    vels = s.sacV(ind);
    ts = s.sact(ind);
    figure(3)
    plot(ts,vels,'o','markeredgecolor','k','markerfacecolor','k','markersize',4)
    xlabel('time [min]','FontSize',18)
    ylabel('Deg/Sec','FontSize',18)
    ylim([0 1200])
    xlim([0 s.sact(end)+0.5])
    grid on
end

%% save data
% sfile = [c.output_prefix '_' datestr(date,'yy') datestr(date,'mm') datestr(date,'dd') '_' num2str(c.filesufix)] ;
% save(['Output/' sfile '.mat'],'PDS','c','s','-mat')

%%
if s.repeat20
    if s.repeatcount == 40
        c.repeat = 0;
        s.repeat20 = 0;
        s.repeatcount = 0;
        c.tpWindH          = 2;
        c.tpWindW          = 2;
        c.vissac = 1;
    elseif s.repeatcount == 20
        c.vissac = 0;
        c.repeat = 1;
        c.tpWindH          = 3;
        c.tpWindW          = 3;
        c.targetFlashDur = 0.2;
    else
        c.repeat = 1;
    end
end

if c.Rrepeat
    c.repeat = 1;
end
    

%% Connect to Omniplex and get data
if c.connectPLX    
	new = get_Omniplex_data;
    if new ~= -1
        c.userlocs = [c.userlocs; new];
    end
end

% Stop ADC schedule.
Datapixx('StopAdcSchedule');
Datapixx('RegWrRd');

%% Make sure a Dac or Audio schedules are not running before setting a new schedule in the next trial
Datapixx('RegWrRd');    
Dacstatus = Datapixx('GetDacStatus');
while Dacstatus.scheduleRunning == 1
Datapixx('RegWrRd');    
Dacstatus = Datapixx('GetDacStatus');
% fprintf('Reward System running.\n');
end



end

%%
function y = smoothdiff(x)

b = zeros(29,1);
b(1) =  -4.3353241e-04 * 2*pi;
b(2) =  -4.3492899e-04 * 2*pi;
b(3) =  -4.8506188e-04 * 2*pi;
b(4) =  -3.6747546e-04 * 2*pi;
b(5) =  -2.0984645e-05 * 2*pi;
b(6) =   5.7162272e-04 * 2*pi;
b(7) =   1.3669190e-03 * 2*pi;
b(8) =   2.2557429e-03 * 2*pi;
b(9) =   3.0795928e-03 * 2*pi;
b(10) =   3.6592020e-03 * 2*pi;
b(11) =   3.8369002e-03 * 2*pi;
b(12) =   3.5162346e-03 * 2*pi;
b(13) =   2.6923104e-03 * 2*pi;
b(14) =   1.4608032e-03 * 2*pi;
b(15) =   0.0;
b(16:29) = -b(14:-1:1);

if(size(x,1)==1)
  x = x(:);
end

%x2 = [x(14:-1:1,:) ; x];

y = filter(b,1,x);

y = [y(15:size(x,1),:) ; zeros(14,size(x,2))];
y(1:14,:) = 0;

%y = y(14:size(x,1)+13,:);
%y = y(14:size(x,1)+13,:);

y = 1000*y;
end