function [ CordArr, MajorAxe, MajorDir] = BodyCtrLineArea( img_bw, stpsize)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    height=size(img_bw,1);
    width=size(img_bw,2);
    %imagesc(img_bw); return;
    [M1, M2] = MomentInertia(img_bw);
    [V, D]=eig(M2(1:2,1:2));
    V2=abs(V);
    [si, sd]=sort([D(1,1), D(2,2)]);
    if V(1, sd(2))>=0
        ux=[V(:,sd(2));0];
    else
        ux=[-V(:,sd(2));0];
    end
    crss_ctr = CrosssectArea(img_bw, M1(1:2), ux);
    [M1crss, M2crss] = MomentInertia(crss_ctr);
    CordArr=M1crss;
    [V, D]=eig(M2crss(1:2,1:2));
    M1crss0=M1crss;
    ux0=ux;
    MajorAxe=[D(2,2)];
    MajorDir=[V(:,1)', V(:,2)'];
    img_crss=CrosssectArea(img_bw, M1crss0, ux, 'distance', stpsize);
    nmax=100;
    ncnt=0;
    while numel(find(img_crss>0))>0 && ncnt<nmax
        [M1crss2, M2crss] = MomentInertia(img_crss);
        %[M1crss2(:,1), sum(ux.*(M1crss2-M1crss)')/norm(M1crss2-M1crss)]
        if sum(ux.*(M1crss2-M1crss)')/norm(M1crss2-M1crss) <.5;
        %    break;
        end
        CordArr=[CordArr; M1crss2];
        [V, D]=eig(M2crss(1:2,1:2));
        MajorAxe=[MajorAxe; D(2,2)];
        MajorDir=[MajorDir; V(:,1)', V(:,2)'];
        ux=(M1crss2-M1crss)'*.5+ux;
        ux=ux/norm(ux);
        M1crss=M1crss2;
        img_crss=CrosssectArea(img_bw, M1crss, ux, 'distance', stpsize);
        ncnt=ncnt+1;
    end
    itrlst=numel(CordArr(:,1));
    ntry=3;
    if itrlst>1 
        ptrs=floor(ones(ntry,1)*CordArr(itrlst,1:2)+[ux(1)*linspace(0.5, stpsize, ntry)', ux(2)*linspace(0.5, stpsize, ntry)']+.5);
        indx=(ptrs(:,2)-1)*height+ptrs(:,1);
        indx(find(indx<=0))=1;
        ptrs=ptrs(find(img_bw(indx)>0),:);
        if numel(ptrs)
            distptr=sqrt(ptrs(:,1).^2+ptrs(:,2).^2);
            distmax=max(distptr);
            if distmax>0
                indmult=find(distptr==distmax);
                if numel(indmult)>1
                    CordArr=[CordArr; [sum(ptrs(indmult, :))/numel(indmult), 1]];
                else
                    CordArr=[CordArr; [ptrs(indmult, :), 1]];
                end
            end
    end
    img_crss=CrosssectArea(img_bw, M1crss0, ux0, 'distance', -stpsize);
    D(2,2)=2;
    ux=ux0;
    nmax=100;
    ncnt=0;

    while numel(find(img_crss>0))>0 & ncnt<nmax
        [M1crss2, M2crss] = MomentInertia(img_crss);
        %[M1crss2(:,1), sum(ux.*(M1crss-M1crss2)')/norm(M1crss2-M1crss)]
        if sum(ux.*(M1crss-M1crss2)')/norm(M1crss-M1crss2) <.5;
        %    break;
        end
        CordArr=[M1crss2; CordArr];
        [V, D]=eig(M2crss(1:2, 1:2));
        MajorAxe=[D(2,2); MajorAxe];
        MajorDir=[V(:,1)', V(:,2)'; MajorDir];
        ux=(M1crss-M1crss2)'*.5+ux;
        ux=ux/norm(ux);
        M1crss=M1crss2;
        img_crss=CrosssectVol(img_bw, M1crss, ux, 'distance', -stpsize);
        ncnt=ncnt+1;
    end
    itrlst=numel(CordArr(:,1));
    if itrlst>1 
        ptrs=floor(ones(ntry,1)*CordArr(1,1:2)+[ux(1)*linspace(0.5, stpsize, ntry)', ux(2)*linspace(0.5, stpsize, ntry)']+.5);
        indx=(ptrs(:,2)-1)*height+ptrs(:,1);
        ptrs=ptrs(find(img_bw(indx)>0),:);
        
        if numel(ptrs)
            distptr=sqrt(ptrs(:,1).^2+ptrs(:,2).^2);
        
            distmax=max(distptr(:));
            if distmax>0
                indmult=find(distptr==distmax);
                if numel(indmult)>1
                    CordArr=[[sum(ptrs(indmult, :))/numel(indmult), 1]; CordArr];
                else
                    CordArr=[[ptrs(indmult, :), 1]; CordArr];
                end
            end
        end
    end        
end

