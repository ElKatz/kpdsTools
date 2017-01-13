function [PDS ,c ,s] = savedata(PDS ,c ,s)

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

if c.preinjection==0 && c.postinjection==0
c.filename=strcat('R', Datename, '_attn_blkdsgn');
elseif c.preinjection==1 && c.postinjection==0
c.filename=strcat('R', Datename, '_attn_blkdsgn_preinj');    
elseif c.preinjection==0 && c.postinjection==1
c.filename=strcat('R', Datename, '_attn_blkdsgn_postinj');        
end

save(['../Data/' c.filename '.mat'],'PDS','c','s','-mat');