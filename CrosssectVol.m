function [ Vol_crss ] = CrosssectVol(Vol_bw, C, V, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    [ Vol_bw, C, V, Dthick, Dist] = init(Vol_bw, C, V, varargin{:});
    height=size(Vol_bw, 1);
    width=size(Vol_bw, 2);
    depth=size(Vol_bw, 3);
    [x, y, z]=meshgrid(1:width, 1:height, 1:depth);
    Vol_crss=zeros(size(Vol_bw));
    indxbw=find(Vol_bw>0);
    vdist=(x(indxbw)-C(1))*V(1)+(y(indxbw)-C(2))*V(2)+(z(indxbw)-C(3))*V(3);
    indx=find(vdist>Dist-.5*Dthick & vdist<Dist+.5*Dthick);
    Vol_crss(indxbw(indx))=1;
end

%% init (initialize)
function [ Vol_bw, C, V, Dthick, Dist] = init(Vol_bw, C, V, varargin)
    Dthick=1; Dist=0;
    for i=1:2:nargin-3
        switch varargin{i}
            case 'thickness'
                Dthick=varargin{i+1};
            case 'distance'
                Dist=varargin{i+1};
        end
    end
    
    
    if isempty(Dthick),  Dthick=1; end
    if isempty(Dist), Dist=0; end
end