function [M1, M2] = MomentInertia(Vol_bw)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    height=size(Vol_bw, 1);
    width=size(Vol_bw, 2);
    depth=size(Vol_bw, 3);
    [x, y, z]=meshgrid(1:width, 1:height, 1:depth);
    indxbw=find(Vol_bw>0);
    vol=numel(indxbw);
    M1=[sum(x(indxbw)), sum(y(indxbw)),sum(z(indxbw))]/vol;
    %rsqr=sum(x(indxbw).^2+y(indxbw).^2+z(indxbw).^2);
    %M2=[rsqr-sum(x(indxbw).*x(indxbw)), -sum(x(indxbw).*y(indxbw)), -sum(x(indxbw).*z(indxbw));...
    %    0, rsqr-sum(y(indxbw).*y(indxbw)), -sum(y(indxbw).*z(indxbw));...
    %    0, 0, rsqr-sum(z(indxbw).*z(indxbw))]/vol;
    M2=[sum(x(indxbw).*x(indxbw)), sum(x(indxbw).*y(indxbw)), sum(x(indxbw).*z(indxbw));...
        0, sum(y(indxbw).*y(indxbw)), sum(y(indxbw).*z(indxbw));...
        0, 0, sum(z(indxbw).*z(indxbw))]/vol;
    M2(2,1)=M2(1,2); M2(3,1)=M2(1,3); M2(3,2)=M2(2,3);
    M2=M2-M1'*M1;
    
end

