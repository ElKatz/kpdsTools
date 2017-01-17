function [PDS ,c ,s] = savedata(PDS ,c ,s)
%% save data
if c.preinjection==0 && c.postinjection==0
sfile = [c.output_prefix '_' datestr(date,'yymmdd') '_' num2str(c.filesuffix)];
elseif c.preinjection==1 && c.postinjection==0
sfile = [c.output_prefix '_' datestr(date,'yymmdd') '_preinj'];
elseif c.preinjection==0 && c.postinjection==1
sfile = [c.output_prefix '_' datestr(date,'yymmdd') '_postinj'];
end

save(['../Data/' sfile '.mat'],'PDS','c','s','-mat');