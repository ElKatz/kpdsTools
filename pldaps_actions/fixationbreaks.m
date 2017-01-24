function [PDS ,c ,s] = fixationbreaks(PDS ,c ,s)

fixationbreak_trials=find(PDS.timebrokefix>0);
fixationbreak_times=round(1000*PDS.timebrokefix(PDS.timebrokefix>0));
fixationacquire_times=round(1000*PDS.fpentered(PDS.timebrokefix>0));

for i=1:size(fixationbreak_trials,2)
    if (fixationbreak_times(i)-fixationacquire_times(i))>250
fixationbreak_em{i}=PDS.EyeXYZ{fixationbreak_trials(i)}(:,fixationbreak_times(i)-50:fixationbreak_times(i)+10);
subplot(3,1,1),plot(fixationbreak_em{i}(1,:)');
hold on
subplot(3,1,2),plot(fixationbreak_em{i}(2,:)');
hold on
subplot(3,1,3),plot(fixationbreak_em{i}(3,:)');
hold on
end

end
end