function [s, img2shft, varargout]=im2compare(img1, img2, varargin)
[rblur, rtred, vrange] = init(varargin{:});
varargout{1}=[];
diffx1=[diff(img1(:,1:2), 1, 2), (img1(:, 3:end)-img1(:, 1:end-2))*.5, diff(img1(:,end-1:end), 1, 2)];
diffx1=[diff(diffx1(:,1:2), 1, 2), (diffx1(:, 3:end)-diffx1(:, 1:end-2))*.5, diff(diffx1(:,end-1:end), 1, 2)];
diffy1=[diff(img1(1:2, :)); (img1(3:end, :)-img1(1:end-2, :))*.5; diff(img1(end-1:end, :))];
diffy1=[diff(diffy1(1:2, :)); (diffy1(3:end, :)-diffy1(1:end-2, :))*.5; diff(diffy1(end-1:end, :))];
laplace1=im2blur(diffx1+diffy1, rblur);

diffx2=[diff(img2(:,1:2), 1, 2), (img2(:, 3:end)-img2(:, 1:end-2))*.5, diff(img2(:,end-1:end), 1, 2)];
diffx2=[diff(diffx2(:,1:2), 1, 2), (diffx2(:, 3:end)-diffx2(:, 1:end-2))*.5, diff(diffx1(:,end-1:end), 1, 2)];
diffy2=[diff(img2(1:2, :)); (img2(3:end, :)-img2(1:end-2, :))*.5; diff(img2(end-1:end, :))];
diffy2=[diff(diffy2(1:2, :)); (diffy2(3:end, :)-diffy2(1:end-2, :))*.5; diff(diffy2(end-1:end, :))];
laplace2=im2blur(diffx2+diffy2, rblur);

if ~isempty(rtred)
    laplace1=imresize(laplace1, rtred);
    laplace2=imresize(laplace2, rtred);
end


if ~isempty(vrange)
   [mx, my]=meshgrid(-abs(vrange(1)):abs(vrange(1)), -abs(vrange(2)):abs(vrange(2))); 
   mscore=zeros(size(mx));
   for i=1:numel(mx)
       mscore(i)=scoreImgDiff(laplace1, laplace2, [mx(i), my(i)]);
   end
   varargout{1}=mscore;
   indmin=min(find(mscore(:)==min(mscore(:))));
   s0=[mx(indmin), my(indmin)];
else
   s0=[0, 0];
end


func=@(b) scoreImgDiff(laplace1, laplace2, b);
s = fminsearch(func, s0);
if ~isempty(rtred)
    s=s/rtred;
end
img2shft=imshft(img2, s);
img2shft(isnan(img2shft))=img1(isnan(img2shft));
end

function [scr] = scoreImgDiff(img1, img2, vshift)
nshift=floor(abs(vshift)+1.5);
img2t=im2circshift(img2, vshift);
imgdiff=imsubtract(img1, img2t);
scr=nansum(imgdiff(:).^2)/sum(~isnan(imgdiff(:)));
end

function [imgshft] = im2circshift(img, vshift)
nshift=floor(abs(vshift)+1.5);
imgt=[img(end-nshift(2)+1: end, :); img; img(1: nshift(2), :)];
imgt=[imgt(:, end-nshift(1)+1 :end), imgt, imgt(:, 1:nshift(1))];
imgshft=imshft(imgt, vshift); 
imgshft=imgshft(nshift(2)+1: nshift(2)+size(img, 1), nshift(1)+1:nshift(1)+size(img, 2));
end

function [rblur, rtred, vrange] = init(varargin)
for i=2:2:nargin
    switch varargin{i-1}
        case 'rSmooth'
            rblur=varargin{i};  
        case 'Reduct'
            rtred=varargin{i};
        case 'Range'
            vrange=varargin{i};
    end
end
if ~exist('rblur', 'var'), rblur=5; end;
if ~exist('rtred', 'var'), rtred=[]; end;
if ~exist('vrange', 'var'), vrange=[]; end;
end