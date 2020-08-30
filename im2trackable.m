function [imgtr] = im2trackable (img0, varargin)
[radJ, sgn] = init(varargin{:});
%K=wiener2(img0, 3,3);
mbessel=BesselRing(7*radJ, radJ);
corr=correlationNeqfst(img0, mbessel, size(img0, 2), size(img0,1));
imgtr=corr.*(sgn*corr>0);
imgtr(isnan(imgtr))=0;
end

function [radJ, sgn] = init(varargin)

for i=2:2:nargin
switch varargin{i-1}
    case 'BesselRadius'
    radJ=varargin{i};
    case 'Sign'
        sgn=varargin{i};
end
    
end

if ~exist('radJ', 'var'), radJ=3; end;
if ~exist('sgn', 'var'), sgn=1; end;
end