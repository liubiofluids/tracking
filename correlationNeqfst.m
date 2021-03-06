function corr = correlationNeqfst(data0, datatrack, offsetx, offsety, varargin)
%% size(data1) > size(datatrack)
valstd=std(double(data0(:)));
imgsz=size(data0);
fltsz=size(datatrack);
data1=ones(3*imgsz)*mean(data0(:));
data1(imgsz(1)+1:2*imgsz(1), imgsz(2)+1:2*imgsz(2))=data0; % enlarged data0
data1=data1(floor(imgsz(1)-.5*(fltsz(1)-imgsz(1)+offsetx)):floor(2*imgsz(1)+.5*(fltsz(1)-imgsz(1)+offsetx)+1), floor(imgsz(2)-.5*(fltsz(2)-imgsz(2)+offsety)):floor(2*imgsz(2)+.5*(fltsz(2)-imgsz(2)+offsety)+1));
corr=zeros(offsety, offsetx);
[xshft, yshft]=meshgrid(1:offsetx, 1:offsety);
szdata=fliplr(size(datatrack))-1; %was size(datatrack)-1 on 07/26/2020

if exist('prcorr2')==3
    funcorr=@(A, B) prcorr2(A, B);
else
    funcorr=@(A, B) corr2(A, B);
    warning('Install "prcorr2" (a faster correlation code) for better performance.'); 
end
n=numel(corr);
for i=1:n
tdata=imcrop(data1, [xshft(i), yshft(i), szdata]); 
corr(i)=funcorr(tdata, datatrack)*std(double(tdata(:)))/valstd;
end
