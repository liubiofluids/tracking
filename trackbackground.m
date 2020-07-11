function varargout = trackbackground(varargin)
% TRACKBACKGROUND MATLAB code for trackbackground.fig
%      TRACKBACKGROUND, by itself, creates a new TRACKBACKGROUND or raises the existing
%      singleton*.
%
%      H = TRACKBACKGROUND returns the handle to a new TRACKBACKGROUND or the handle to
%      the existing singleton*.
%
%      TRACKBACKGROUND('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKBACKGROUND.M with the given input arguments.
%
%      TRACKBACKGROUND('Property','Value',...) creates a new TRACKBACKGROUND or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackbackground_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackbackground_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackbackground

% Last Modified by GUIDE v2.5 13-Dec-2019 00:11:22

% Begin initialization code - DO NOT EDIT

% Required functions: imshft
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackbackground_OpeningFcn, ...
                   'gui_OutputFcn',  @trackbackground_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before trackbackground is made visible.
function trackbackground_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackbackground (see VARARGIN)

% Choose default command line output for trackbackground
handles.output = hObject;

handles.stattrack = 0;
handles.statmask = 0;
handles.statstage = 1;

handles.vcord=[];
handles.vdisp=[];
handles.mask=[];
handles.img0=[];
handles.imgc=[];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trackbackground wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trackbackground_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

 indcur=floor(get(hObject,'Value'));
 set(handles.edit4, 'String', num2str(indcur));
 refreshimg(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles.stattrack = ~handles.stattrack;
handles.img0=[];
guidata(hObject, handles);
if handles.stattrack
    set(hObject, 'String', 'Stop');
else
    set(hObject, 'String', 'Run');
end

sindmin = get(handles.edit2, 'String');
sindmax = get(handles.edit3, 'String');
sindcur = get(handles.edit4, 'String');
indmin = str2num(sindmin);
indmax = str2num(sindmax);
indcur = str2num(sindcur);

stattrack=handles.stattrack;


if stattrack && ~isempty(get(handles.ed_video_file, 'String'))
aviobj=VideoWriter(get(handles.ed_video_file, 'String'));
aviobj.FrameRate=12;
framestep=str2num(get(handles.edit38, 'String'));
rawfps=str2num(get(handles.ed_fps_raw, 'String'));
posax=get(handles.axes1,'Position');
width=str2num(get(handles.edit_width, 'String'));
height=str2num(get(handles.edit_height, 'String'));

if isempty(get(handles.ed_roi_x, 'String'))
    ROI=[1, 1, str2num(get(handles.edit_width, 'String')), str2num(get(handles.edit_height, 'String'))];
else
    ROI=[str2num(get(handles.ed_roi_x, 'String')), str2num(get(handles.ed_roi_y, 'String'))...
        ,str2num(get(handles.ed_roi_w, 'String')), str2num(get(handles.edit43, 'String'))];
end

ind0=indcur;
aviobj.open();
end

while stattrack && indcur<=indmax
    if(str2num(get(handles.ed_object_r, 'String'))>0)
        tracking(hObject, handles);
        drawcircle(handles);
    end
    pause(0.1);
    handles = guidata(hObject);
    stattrack=handles.stattrack;
    guidata(hObject, handles);
   
    indcur=indcur+1;
    if indcur>indmax
        break;
    end
    
    set(handles.edit4, 'String', num2str(indcur));
    set(handles.slider1, 'Value', indcur);
    if exist('aviobj', 'var')
        if mod(indcur-ind0, framestep)==0
            h=getframe(handles.axes1);
            imgdata=imcrop(imresize(flipud(h.cdata), [height, width]), ROI);
            writeVideo(aviobj, imresize(imgdata, [720, ROI(3)/ROI(4)*720]));
        end
    end
    refreshimg(hObject, handles);
end
set(hObject, 'String', 'Run');




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = get(handles.edit1, 'String');
sindmin = get(handles.edit2, 'String');
sindmax = get(handles.edit3, 'String');
sindcur = get(handles.edit4, 'String');
indmin = str2num(sindmin);
indmax = str2num(sindmax);
indcur = str2num(sindcur);
if(indcur < indmin)
    indcur = indmin;
end
if(indcur >indmax)
    indmax = indcur;
end
set(handles.edit3, 'String', num2str(indmax));
set(handles.edit4, 'String', num2str(indcur));
set(handles.slider1, 'Min', indmin);
set(handles.slider1, 'Max', indmax);
set(handles.slider1, 'Value', indcur);
set(handles.slider1, 'SliderStep', [1/(indmax-indmin), 10/(indmax-indmin)]);
refreshimg(hObject, handles);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
set(hObject, 'PickableParts', 'all');

function refreshimg(hObject, handles)
fdname = get(handles.edit1, 'String');
indcur = str2num(get(handles.edit4, 'String'));
handles=guidata(hObject);
try 
    str = ls([fdname, sprintf('*%d.*', indcur)]);
catch lserr
    try str = ls([fdname, sprintf('*-%d.*', indcur)]);
    catch stlerr
        str = ls([fdname, sprintf('*%05d.*', indcur)]);
    end
end

cfile = textscan(str, '%[^\n]');

for istr=1:length(cfile{1})
    isnum=cfile{1}{istr}>='0' & cfile{1}{istr}<='9';
    [labeled, nnum] = bwlabel(isnum, 4);
    indfrmstr=str2num(cfile{1}{istr}(labeled==nnum));
    if indfrmstr==indcur
        indcr=istr;
        break;
    end
end

imgflname=cfile{1}{indcr};
img=double(imread(imgflname));
hold(handles.axes1, 'on');
    delete(findall(handles.axes1, 'Type', 'Patch'));
    delete(findall(handles.axes1, 'Type', 'Image'));
    

if ~isempty(get(handles.ed_bkgrnd_file, 'String'))
    szbkblr=str2double(get(handles.ed_bkblur, 'String'));
cellsmooth=str2num(get(handles.edit24, 'String'));
clussmooth=[str2num(get(handles.edit25, 'String')), str2num(get(handles.edit26, 'String'))];

    if ~isempty(get(handles.ed_file_backmask, 'String'))
        bwmaskfile=get(handles.ed_file_backmask, 'String');
        ifolder_end=strfind(bwmaskfile, '/');
        fld_vdisp=bwmaskfile(1:max(ifolder_end));
        if exist([fld_vdisp, 'vdisp.txt'], 'file')
            vdispmsk=load([fld_vdisp, 'vdisp.txt']);
            [sd, si]=sort(vdispmsk(:,1));
            vdispmsk=vdispmsk(si, :);
            vdispmsk(diff(vdispmsk(:,1))==0, :)=[];
            vstgposmsk=cumsum([0, 0; -vdispmsk(:, 2:3)]);
            vstgposmsk(:,1)=vstgposmsk(:,1)-min(vstgposmsk(:,1))+1;
            vstgposmsk(:,2)=vstgposmsk(:,2)-min(vstgposmsk(:,2))+1;
            imgall_bw=imread(bwmaskfile);
        end
    end

    imgbkname=sprintf(get(handles.ed_bkgrnd_file, 'String'), indcur);
    imgbkgrnd=double(imread(imgbkname));
    if szbkblr>0
        imgbkgrnd=im2blur(imgbkgrnd, szbkblr);
    end

    if exist('imgall_bw', 'var')
        bwmsk=imcrop(imgall_bw, [vstgposmsk(indcur-vdispmsk(1)+1, :), fliplr(size(img))-1]);
        if size(bwmsk, 1)<size(img, 1)
            bwmsk(end+1:size(img, 1), :)=1;
        end
        if size(bwmsk, 2)<size(img, 2)
            bwmsk(:, end+1:size(img, 2))=1;
        end        
         bwmsk=im2blur(bwmsk, cellsmooth)>0.1;
        [labeled, nregime] = bwlabel(bwmsk, 4);
        imgblr=im2blur(img, cellsmooth);
        [xg, yg] = meshgrid(1:size(img,2), 1:size(img, 1));
        F = scatteredInterpolant(xg(bwmsk(:)==0), yg(bwmsk(:)==0), imgblr(bwmsk(:)==0));
        imgmsked=F(xg, yg);
        imgn=img;

        for kr=1:nregime
            imgmskt=bwmsk;
            indregime=labeled==kr;
            indnregime=~indregime;
            imgt=img;
            imgt(indnregime)=nan;
            imgbkt=imgbkgrnd;
            imgbkt(indnregime)=nan;
            imgdiff=imsubtract(imgt, imgbkt);
            imgn(indregime)=imgdiff(indregime)+imgblr(indregime);
        end
        img=imgn;

        img=imsubtract(img, imopen(img, strel('disk', cellsmooth)));
    else
        img=imsubtract(img, imgbkgrnd)+mean(imgbkgrnd(:));
    end
end
h=imagesc(adapthisteq(mat2gray(img)), 'Parent', handles.axes1); colormap(gray);
axis(get(h, 'Parent'), [1, size(img, 2), 1, size(img, 1)]);
set(get(h, 'Parent'), 'xtick', []);
set(get(h, 'Parent'), 'ytick', []);
set(h, 'HitTest', 'off', 'PickableParts', 'none');

set(handles.edit_width, 'String', num2str(size(img, 2)));
set(handles.edit_height, 'String', num2str(size(img, 1)));
handles.imgc=img;
guidata(hObject, handles);

function tracking(hObject, handles)
fdname = get(handles.edit1, 'String');
indcur = str2num(get(handles.edit4, 'String'));
outfolder=get(handles.ed_outpath, 'String');
if ~exist(outfolder, 'file')
   mkdir(outfolder);
end

try 
    str = ls([fdname, sprintf('*%d.*', indcur)]);
catch lserr
    try str = ls([fdname, sprintf('*-%d.*', indcur)]);
    catch stlerr
        str = ls([fdname, sprintf('*%05d.*', indcur)]);
    end
end

cfile = textscan(str, '%[^\n]', 1);
imgflname=cfile{1}{1};

if ~isempty(handles.imgc)

    refreshimg(hObject, handles);

end

handles=guidata(hObject);
img=handles.imgc;
guidata(hObject, handles);

thrshld=[str2num(get(handles.edit9, 'String')), str2num(get(handles.edit10, 'String'))];
areamin=str2num(get(handles.edit_area1, 'String'));
areamax=str2num(get(handles.edit_area2, 'String'));
cellsmooth=str2num(get(handles.edit24, 'String'));
clussmooth=[str2num(get(handles.edit25, 'String')), str2num(get(handles.edit26, 'String'))];
winsz=[str2num(get(handles.edit5, 'String')), str2num(get(handles.edit7, 'String'))];
gcord=[str2num(get(handles.edit19, 'String')),str2num(get(handles.edit20, 'String'))];

if clussmooth(1)==0
    if ~get(handles.rb_trackring_true, 'Value')
        if winsz==[1,1]
            vcord=gcord;
        else
            [vcord, imgtracked, vdark, shapeconf]=trk_trackbactflt(img, 'Threshold', thrshld(1), 'Areamin', areamin, 'Areamax', areamax...
            , 'GuessCentroid', gcord, 'WindowSize', winsz, 'CellShape', 1, 'Smooth', cellsmooth, 'RadiusFilter', clussmooth(1), 'Mask', handles.mask);
            save([outfolder, sprintf('cshp%05d.mat', indcur)], 'shapeconf');
            appendfile([indcur, vdark], [outfolder, 'vdark.txt']);
        end
    else
        xyrange=[str2num(get(handles.ed_speed_x, 'String')), str2num(get(handles.edit8, 'String'))];
        [vcord, msm]=trk_imRing2Center(img, xyrange, 'GuessCentroid', gcord, 'WinSize', winsz, 'rRange', [1, str2num(get(handles.ed_object_r, 'String'))]);

    end
else
    [vcord, imgtracked, vdark]=trk_trackCluster(img, 'Threshold', thrshld(1), 'Areamin', areamin, 'Areamax', areamax...
        , 'GuessCentroid', gcord, 'WindowSize', winsz, 'RadiusFilter', clussmooth(1), 'BesselRadius', clussmooth(2), 'Mask', handles.mask);
            appendfile([indcur, vdark], [outfolder, 'vdark.txt']);
end
set(handles.edit19, 'String', num2str(vcord(1)));
set(handles.edit20, 'String', num2str(vcord(2)));

handles=guidata(hObject);
handles.vcord=[handles.vcord; [indcur, vcord]];
guidata(hObject, handles);
if handles.statstage
    pivconf=struct(...
        'interrogationarea', str2num(get(handles.ed_piv_area, 'String')), ...
        'step', str2num(get(handles.ed_piv_step, 'String')), ...
        'subpixfinder', 1, ...
        'mask_inpt', [], ...
        'roi_inpt', [],...
        'passes', str2num(get(handles.ed_piv_pass, 'String')), ...
        'int2', str2num(get(handles.ed_piv_area, 'String')), ...
        'int3', str2num(get(handles.ed_piv_area, 'String')), ...
        'int4', str2num(get(handles.ed_piv_area, 'String')), ...
        'imdeform', '*spline',...
        'repeat', 0,...
        'mask_auto', 0);
    if ~isempty(handles.mask)
        for k=1:length(handles.mask)
            pivconf.mask_inpt{k,1}=handles.mask{k}(:,1);
            pivconf.mask_inpt{k,2}=handles.mask{k}(:,2);
        end
    end
    try 
        str = ls([fdname, sprintf('*%d.*', indcur-1)]);
    catch lserr
        try str = ls([fdname, sprintf('*-%d.*', indcur-1)]);
        catch stlerr
            str = ls([fdname, sprintf('*%05d.*', indcur-1)]);
        end
    end
    cfile = textscan(str, '%[^\n]', 1);
    imgflname=cfile{1}{1};
    handles=guidata(hObject);
 
    if isempty(handles.img0)
        if exist(imgflname, 'file')
            img0=double(imread(imgflname));
        else
            img0=img;
        end

    else
        img0=handles.img0;
    end
    
    if ~isempty(handles.mask)
            imgmask=zeros(size(img0));
            for k=1:length(handles.mask)
                maskk=poly2mask(handles.mask{k}(:,1), handles.mask{k}(:,2), size(img0, 1), size(img0, 2));
                imgmask=imgmask|maskk;
            end

    end
    guidata(hObject, handles);
    nanmask=ones(size(img));
    if exist('imgmask', 'var')
        nanmask(imgmask)=nan;
    end
    invreduct=max([1, str2num(get(handles.ed_drift_multip, 'String'))]);
    vrange=max([floor([str2num(get(handles.ed_speed_x, 'String')), str2num(get(handles.ed_speed_x, 'String'))]/invreduct+.5); ones(1,2)]);
    [vdisp, imgshfted, mscore]=im2compare(img.*nanmask, img0, 'Reduct', 1./invreduct, 'Range', vrange);
    imgshfted=imshft(img0, vdisp);
    imgshfted(isnan(imgshfted))=img(isnan(imgshfted));
    img0=imgshfted*0.9+img*0.1;
    handles=guidata(hObject);
    handles.vdisp=[handles.vdisp; [indcur, vdisp]];
    handles.img0=img0;
    guidata(hObject, handles);    
    imwrite(img0/max(img0(:)), '~/Downloads/imgmask.jpg');
else
    vdisp=[]; 
    if ~isempty(handles.vdisp)
        vdisp=handles.vdisp(handles.vdisp(:,1)==indcur, 2:3);
        if size(vdisp, 1)>1
            vdisp=vdisp(end, :);
        end
    end
    if isempty(vdisp)
        vdisp=[0, 0];
        handles=guidata(hObject);
        handles.vdisp=[handles.vdisp; [indcur, vdisp]];
        guidata(hObject, handles);
    end
    img0=img;
end

[sd, si]=sort(handles.vdisp(:,1));
vdispsrt=handles.vdisp(si, :);
vdispsrt(diff(vdispsrt(:,1))==0, :)=[];
vdispsrt(:,2:3)=cumsum(vdispsrt(:,2:3));
[sd, si]=sort(handles.vcord(:,1));
vcordsrt=handles.vcord(si, :);
vcordsrt(diff(vcordsrt(:,1))==0, :)=[];

[indcom, icord, idisp]=intersect(vcordsrt(:,1), vdispsrt(:,1));
vcordsrt=vcordsrt(icord, :);
vdispsrt=vdispsrt(idisp, :);
indend=find(vcordsrt(:,1)==indcur);
vcordabs=vcordsrt(1:indend, 2:3)-vdispsrt(1:indend, 2:3);
delete(findall(gcf, 'Type', 'Line'));

htraj=plot(handles.axes1, vcordabs(:,1)-vcordabs(end, 1)+vcord(1), vcordabs(:,2)-vcordabs(end, 2)+vcord(2), 'g');
set(htraj, 'LineWidth', 2,  'HitTest', 'off', 'PickableParts', 'none');

handles.img0=img0;

guidata(hObject, handles);
appendfile([indcur, vcord], [outfolder, 'vcord.txt']);
appendfile([indcur, vdisp], [outfolder, 'vdisp.txt']);

    



function drawcircle(handles)
hold on;
hlines=findall(handles.axes1, 'Type', 'Line');
for i=1:length(hlines)
    if get(hlines(i), 'LineWidth') == 0.5 && strcmp(get(hlines(i), 'LineStyle'), '--')
        delete(hlines(i));
    elseif get(hlines(i), 'LineWidth') == 1.5 && strcmp(get(hlines(i), 'LineStyle'), '-') && norm(get(hlines(i), 'Color')-[1,1,1])==0

        delete(hlines(i));
    end
end

x=str2num(get(handles.edit19, 'String'));
y=str2num(get(handles.edit20, 'String'));
if handles.statmask
    r=str2num(get(handles.edit30, 'String'));
else
    r=str2num(get(handles.ed_object_r, 'String'));
end

hcirc=viscircles(handles.axes1, [x,y], r, 'LineWidth', .5, 'LineStyle', '--');
set(hcirc, 'HitTest', 'off', 'PickableParts', 'none');

function showmask(handles)
mask=handles.mask;
delete(findall(handles.axes1, 'Type', 'Patch'));
hold on;
if ~isempty(mask)
    for i=1:length(mask)
        h=fill(mask{i}(:,1), mask{i}(:, 2), 'r', 'Parent', handles.axes1);
        set(h, 'HitTest', 'off', 'PickableParts', 'none');
    end
end

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_speed_x_Callback(hObject, eventdata, handles)
% hObject    handle to ed_speed_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_speed_x as text
%        str2double(get(hObject,'String')) returns contents of ed_speed_x as a double


% --- Executes during object creation, after setting all properties.
function ed_speed_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_speed_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vcp=get(hObject, 'CurrentPoint'); % get the position of the cursor
set(handles.edit19, 'String', num2str(vcp(1,1)));
set(handles.edit20, 'String', num2str(vcp(1,2)));
drawcircle(handles);

function ed_outpath_Callback(hObject, eventdata, handles)
% hObject    handle to ed_outpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_outpath as text
%        str2double(get(hObject,'String')) returns contents of ed_outpath as a double


% --- Executes during object creation, after setting all properties.
function ed_outpath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_outpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_width_Callback(hObject, eventdata, handles)
% hObject    handle to edit_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_width as text
%        str2double(get(hObject,'String')) returns contents of edit_width as a double


% --- Executes during object creation, after setting all properties.
function edit_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_height_Callback(hObject, eventdata, handles)
% hObject    handle to edit_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_height as text
%        str2double(get(hObject,'String')) returns contents of edit_height as a double


% --- Executes during object creation, after setting all properties.
function edit_height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_object_r_Callback(hObject, eventdata, handles)
% hObject    handle to ed_object_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_object_r as text
%        str2double(get(hObject,'String')) returns contents of ed_object_r as a double


% --- Executes during object creation, after setting all properties.
function ed_object_r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_object_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_area1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_area1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_area1 as text
%        str2double(get(hObject,'String')) returns contents of edit_area1 as a double


% --- Executes during object creation, after setting all properties.
function edit_area1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_area1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_area2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_area2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_area2 as text
%        str2double(get(hObject,'String')) returns contents of edit_area2 as a double


% --- Executes during object creation, after setting all properties.
function edit_area2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_area2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles.stattrack = ~handles.stattrack;
handles.img0=[];
guidata(hObject, handles);

sindmin = get(handles.edit2, 'String');
sindmax = get(handles.edit3, 'String');
sindcur = get(handles.edit4, 'String');
indmin = str2num(sindmin);
indmax = str2num(sindmax);
indcur = str2num(sindcur);

stattrack=handles.stattrack;

if indcur<=indmax && indcur>=indmin 
    
    tracking(hObject, handles);
    drawcircle(handles);
    pause(0.1);
    winsz=[str2num(get(handles.edit5, 'String')), str2num(get(handles.edit7, 'String'))];
    if winsz==[1, 1];
        if indcur<indmax
            indcur=indcur+1;
            set(handles.edit4, 'String', num2str(indcur));
            set(handles.slider1, 'Value', indcur);
            refreshimg(hObject, handles);
        end
    end
end


% --- Executes on button press in pushbutton_mask.
function pushbutton_mask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
handles.statmask = ~handles.statmask;
if handles.statmask
    set(hObject, 'String', 'Done');
    showmask(handles);
else
    r=str2num(get(handles.edit30, 'String'));
    x=str2num(get(handles.edit19, 'String'));
    y=str2num(get(handles.edit20, 'String'));
    if str2num(get(handles.edit29, 'String'))==0
        vx=x+r*cos(linspace(0,2*pi-2*pi/33, 32));
        vy=y+r*sin(linspace(0,2*pi-2*pi/33, 32));
        hold on;
    	h=fill(vx, vy, 'r', 'Parent', handles.axes1);
        set(h, 'HitTest', 'off', 'PickableParts', 'none');
        handles.mask=[handles.mask, {[vx(:), vy(:)]}];
    else

        width=str2num(get(handles.edit_width, 'String'));
        height=str2num(get(handles.edit_height, 'String'));
        imgmask=zeros(height, width);
        [xm, ym]=meshgrid(1:width, 1:height);
        xm=xm-x;
        ym=ym-y;
        rm=sqrt(xm.^2+ym.^2);
        imgmask(rm<r)=1;
        imgmask(ym(:,1)<=0, :)=1; % to avoid a simply connected mask
        [B,L] = bwboundaries(1-imgmask,'holes');
        vmask=[];
        for i=length(B)
            vmask=[vmask, {fliplr(B{i})}];
        end
        imgmask(:)=0;
        imgmask(rm<r)=1;
        imgmask(ym(:,1)>=0, :)=1;
        [B,L] = bwboundaries(1-imgmask,'holes');
        for i=length(B)
            vmask=[vmask, {fliplr(B{i})}];
        end
        hold on;
        for i=1:length(vmask)
            h=fill(vmask{i}(:,1),vmask{i}(:,2),'r', 'Parent', handles.axes1);
            set(h, 'HitTest', 'off', 'PickableParts', 'none');
        end
        handles.mask=[handles.mask, vmask];
    end
    set(hObject, 'String', 'Add Mask');
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles.mask=[];
delete(findall(handles.axes1, 'Type', 'Patch'));
guidata(hObject, handles);


function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rad_stage_true.
function rad_stage_true_Callback(hObject, eventdata, handles)
% hObject    handle to rad_stage_true (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rad_stage_true
handles=guidata(hObject);
if get(hObject, 'Value')==1
    handles.statstage=1;
else
    handles.statstage=0;
end

guidata(hObject, handles);


% --- Executes on button press in rad_stage_false.
function rad_stage_false_Callback(hObject, eventdata, handles)
% hObject    handle to rad_stage_false (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rad_stage_false
handles=guidata(hObject);
if get(hObject, 'Value')
    handles.statstage=0;
else
    handles.statstage=1;
end

guidata(hObject, handles);


% --- Executes on button press in pb_mask_load.
function pb_mask_load_Callback(hObject, eventdata, handles)
% hObject    handle to pb_mask_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
outfolder=get(handles.ed_outpath, 'String');
if exist([outfolder, 'pivmask.mat'], 'file')
   data=load([outfolder, 'pivmask.mat']); 
   handles.mask=data.mask;
end

guidata(hObject, handles);


% --- Executes on button press in pb_mask_save.
function pb_mask_save_Callback(hObject, eventdata, handles)
% hObject    handle to pb_mask_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outfolder=get(handles.ed_outpath, 'String');
if ~exist(outfolder, 'file')
    mkdir(outfolder);
end
mask=handles.mask;
save([outfolder, 'pivmask.mat'], 'mask');



function ed_piv_pass_Callback(hObject, eventdata, handles)
% hObject    handle to ed_piv_pass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_piv_pass as text
%        str2double(get(hObject,'String')) returns contents of ed_piv_pass as a double


% --- Executes during object creation, after setting all properties.
function ed_piv_pass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_piv_pass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_drift_multip_Callback(hObject, eventdata, handles)
% hObject    handle to ed_drift_multip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_drift_multip as text
%        str2double(get(hObject,'String')) returns contents of ed_drift_multip as a double


% --- Executes during object creation, after setting all properties.
function ed_drift_multip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_drift_multip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_piv_area_Callback(hObject, eventdata, handles)
% hObject    handle to ed_piv_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_piv_area as text
%        str2double(get(hObject,'String')) returns contents of ed_piv_area as a double


% --- Executes during object creation, after setting all properties.
function ed_piv_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_piv_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_piv_step_Callback(hObject, eventdata, handles)
% hObject    handle to ed_piv_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_piv_step as text
%        str2double(get(hObject,'String')) returns contents of ed_piv_step as a double


% --- Executes during object creation, after setting all properties.
function ed_piv_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_piv_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_mask_disp.
function pb_mask_disp_Callback(hObject, eventdata, handles)
% hObject    handle to pb_mask_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
showmask(handles);


% --- Executes on button press in pb_reload.
function pb_reload_Callback(hObject, eventdata, handles)
% hObject    handle to pb_reload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outfolder=get(handles.ed_outpath, 'String');
if exist([outfolder, 'vcord.txt']) && exist([outfolder, 'vdisp.txt'])
    vcord=load([outfolder, 'vcord.txt']);
    [sd, si]=sort(vcord(:,1));
    vcord=vcord(si, :);
    vcord(find(diff(vcord(:,1))==0), :)=[];
    vdisp=load([outfolder, 'vdisp.txt']);
    [sd, si]=sort(vdisp(:,1));
    vdisp=vdisp(si, :);
    vdisp(find(diff(vdisp(:,1))==0), :)=[];
    try 
        strmult=ls([outfolder, 'mcord*.txt']);
    catch lserr
        strmult=[];
        ccord=[];
    end
    if ~isempty(strmult)
        ccord=[];
        cfile = textscan(strmult, '%[^\n]');
        for i=1:length(cfile{1})
            vcordt=load(cfile{1}{i});
            [sd, si]=sort(vcordt(:,1));
            vcordt=vcordt(si, :);
            vcordt(find(diff(vcordt(:,1))==0), :)=[];
            ccord=[ccord, {vcordt}];
        end
    end
    handles=guidata(hObject);
    handles.vcord=vcord;
    handles.vdisp=vdisp;
    handles.ccord=ccord;
    guidata(hObject, handles);
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vcord=handles.vcord;
[sd, si]=sort(vcord(:,1));
vcord=vcord(si, :);
vcord(find(diff(vcord(:,1))==0), :)=[];
vdisp=handles.vdisp;
[sd, si]=sort(vdisp(:,1));
vdisp=vdisp(si, :);
vdisp(find(diff(vdisp(:,1))==0), :)=[];
vdisp(:,2:3)=cumsum(vdisp(:, 2:3));

[indcom, icord, idisp]=intersect(vcord(:,1), vdisp(:,1));
vcord=vcord(icord, :); 
vdisp=vdisp(idisp, :);
vcordabs=vcord(:, 2:3)-vdisp(:, 2:3);
sindcur = get(handles.edit4, 'String');
indcur = str2num(sindcur);
icur=find(vcord(:,1)==indcur);
if ~isempty(icur)
    vcordabs=vcordabs+repmat(vcord(icur, 2:3)-vcordabs(icur, :), length(vcordabs), 1);
else
    gcord=[str2num(get(handles.edit19, 'String')),str2num(get(handles.edit20, 'String'))];
    vcordabs=vcordabs+repmat(gcord-vcordabs(end, :), length(vcordabs), 1);
end
hold on;
if ~isempty(vcordabs)
delete(findall(gcf, 'Type', 'Line'));
htraj=plot(handles.axes1, vcordabs(:,1), vcordabs(:,2), 'g');
set(htraj, 'LineWidth', 2,  'HitTest', 'off', 'PickableParts', 'none');
end



function ed_video_file_Callback(hObject, eventdata, handles)
% hObject    handle to ed_video_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_video_file as text
%        str2double(get(hObject,'String')) returns contents of ed_video_file as a double


% --- Executes during object creation, after setting all properties.
function ed_video_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_video_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_roi_x_Callback(hObject, eventdata, handles)
% hObject    handle to ed_roi_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_roi_x as text
%        str2double(get(hObject,'String')) returns contents of ed_roi_x as a double


% --- Executes during object creation, after setting all properties.
function ed_roi_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_roi_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_roi_y_Callback(hObject, eventdata, handles)
% hObject    handle to ed_roi_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_roi_y as text
%        str2double(get(hObject,'String')) returns contents of ed_roi_y as a double


% --- Executes during object creation, after setting all properties.
function ed_roi_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_roi_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_roi_w_Callback(hObject, eventdata, handles)
% hObject    handle to ed_roi_w (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_roi_w as text
%        str2double(get(hObject,'String')) returns contents of ed_roi_w as a double


% --- Executes during object creation, after setting all properties.
function ed_roi_w_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_roi_w (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit43_Callback(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit43 as text
%        str2double(get(hObject,'String')) returns contents of edit43 as a double


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit38_Callback(hObject, eventdata, handles)
% hObject    handle to edit38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit38 as text
%        str2double(get(hObject,'String')) returns contents of edit38 as a double


% --- Executes during object creation, after setting all properties.
function edit38_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_fps_raw_Callback(hObject, eventdata, handles)
% hObject    handle to ed_fps_raw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_fps_raw as text
%        str2double(get(hObject,'String')) returns contents of ed_fps_raw as a double


% --- Executes during object creation, after setting all properties.
function ed_fps_raw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_fps_raw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tb_dynamic.
function tb_dynamic_Callback(hObject, eventdata, handles)
% hObject    handle to tb_dynamic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tb_dynamic
    


% --- Executes on button press in pb_snapshot.
function pb_snapshot_Callback(hObject, eventdata, handles)
% hObject    handle to pb_snapshot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_fig_children=get(gcf,'children');
Fig_Axes=findobj(GUI_fig_children,'type','Axes');
fig=figure;ax=axes;clf;
new_handle=copyobj(Fig_Axes,fig);
width=str2num(get(handles.edit_width, 'String'));
height=str2num(get(handles.edit_height, 'String'));

set(fig, 'Position', [200, 1000-640*height/width, 640, 640*height/width]);
set(gca,'ActivePositionProperty','outerposition')
set(gca,'Units','normalized')
set(gca,'Position',[0 0 1 1])

% --- Executes on button press in pb_export.
function pb_export_Callback(hObject, eventdata, handles)
% hObject    handle to pb_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outfolder=get(handles.ed_outpath, 'String');

handles=guidata(hObject);
vcord=handles.vcord;
vdisp=handles.vdisp;
img0=handles.img0;
guidata(hObject, handles);
[sd, si]=sort(handles.vdisp(:,1));
vdispsrt=handles.vdisp(si, :);
vdispsrt(diff(vdispsrt(:,1))==0, :)=[];
vdispsrt(:,2:3)=cumsum(vdispsrt(:,2:3));
[sd, si]=sort(handles.vcord(:,1));
vcordsrt=handles.vcord(si, :);
vcordsrt(diff(vcordsrt(:,1))==0, :)=[];

[indcom, icord, idisp]=intersect(vcordsrt(:,1), vdispsrt(:,1));

vpos=vcordsrt(icord, 2:3)-vdispsrt(idisp, 2:3);
vind=vcordsrt(icord, 1);
save([outfolder, 'vpos.mat'], 'vpos', 'vind');
if ~isempty(img0)
imwrite(img0/max(img0(:)), [outfolder, 'imgcurr.jpg']);
end



function ed_bkgrnd_file_Callback(hObject, eventdata, handles)
% hObject    handle to ed_bkgrnd_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_bkgrnd_file as text
%        str2double(get(hObject,'String')) returns contents of ed_bkgrnd_file as a double


% --- Executes during object creation, after setting all properties.
function ed_bkgrnd_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_bkgrnd_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_bkblur_Callback(hObject, eventdata, handles)
% hObject    handle to ed_bkblur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_bkblur as text
%        str2double(get(hObject,'String')) returns contents of ed_bkblur as a double


% --- Executes during object creation, after setting all properties.
function ed_bkblur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_bkblur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_file_backmask_Callback(hObject, eventdata, handles)
% hObject    handle to ed_file_backmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_file_backmask as text
%        str2double(get(hObject,'String')) returns contents of ed_file_backmask as a double


% --- Executes during object creation, after setting all properties.
function ed_file_backmask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_file_backmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
