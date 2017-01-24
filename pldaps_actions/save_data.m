function [PDS,c,s] = save_data(PDS,c,s)
%% save data
sfile = [c.output_prefix '_' datestr(date,'yy') datestr(date,'mm') datestr(date,'dd') '_' num2str(c.filesufix)] ;
save(['../Data/' sfile '.mat'],'PDS','c','s','-mat')
