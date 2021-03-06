% Load data from Swiss Ranger 
%
% Parameters
%   data_name : the directory name of data
%   dm : index of directory of data
%   j  : index of frame
%
% Author : Soonhac Hong (sxhong1@ualr.edu)
% Date : 4/20/11

% No bad pixel compensation

function [img, x, y, z, c, rtime, error] = LoadSR_no_bpc_time_single_binary(data_name, filter_name, boarder_cut_off, dm, j, scale, type_value)

% if nargin < 6
%     scale = 1;
% end

%apitch=-43+3*dm;
%[prefix, err]=sprintf('../data/d%d_%d/d%d', dm, apitch, dm);
% [prefix, confidence_read] = get_sr4k_dataset_prefix(data_name, dm);
% 
% if j<10
%     [s, err]=sprintf('%s_000%d.dat', prefix, j);
% elseif j<100
%     [s, err]=sprintf('%s_00%d.dat', prefix, j);
% elseif j<1000
%     [s, err]=sprintf('%s_0%d.dat', prefix, j);
% else
%     [s, err]=sprintf('%s_%d.dat', prefix, j);
% end


img=[];
x=[];
y=[];
z=[];
c=[];
error=0;
rtime=0;

%s_binary='D:\soonhac\Project\PNBD\SW\sr4000\SwissRangerSampleGui\data\d1_0001.bdat';
%s_binary='d1_0001.bdat';
%s_binary=sprintf('E:\\data\\motive\\m5_swing_loop_2\\processed_data\\binary_data\\d1_%04d.bdat',j);
%s_binary=sprintf('E:\\data\\swing\\revisiting2_10m\\processed_data\\binary_data\\d1_%04d.bdat',j);
%s_binary=sprintf('E:\\data\\Amir\\processed_data\\exp1_bus_door_straight_150_Copy\\binary_data\\d1_%04d.bdat',j);

%s_binary=sprintf('D:\\Soonhac\\Data\\sr4k\\exp1_bus_door_straight_150_Copy\\binary_data\\d1_%04d.bdat',j);
%s_binary=sprintf('D:\\Soonhac\\Data\\sr4k\\smart_cane\\binary_data\\d1_%04d.bdat',j); % for KCLCD test

%s_binary=sprintf('C:\\SC-DATA-TRANSFER\\d1_0001.bdat');

s_binary=sprintf('C:\\SC-DATA-TRANSFER\\d1_%04d.bdat',j);  % for running demo
%s_binary=sprintf('D:\\Soonhac\\Data\\sr4k\\smart_cane\\exp2_etas523_lefthallway_exp1\\d1_%04d.bdat',j); % for KCLCD test

confidence_read=1;
fw=1;
sr4k_image_width = 176;
sr4k_image_height = 144;
sr4k_image_size=[sr4k_image_height sr4k_image_width];

%t_pre = clock; %cputime;
t_pre = tic;

%a = load(s);    % text file

fileID=fopen(s_binary);
if fileID==-1
    %disp('File open fails !!');
    error=-1;
    return;
end
%a=fread(fileID,[sr4k_image_width*3,sr4k_image_height],'float');
%fseek(fileID,sr4k_image_height*3*sr4k_image_width,'bof');
%b=fread(fileID,[sr4k_image_width*2,sr4k_image_height],'uint16');
%a=vec2mat(a',sr4k_image_width);

z=fread(fileID,[sr4k_image_width,sr4k_image_height],'float');
x=fread(fileID,[sr4k_image_width,sr4k_image_height],'float');
y=fread(fileID,[sr4k_image_width,sr4k_image_height],'float');
img=fread(fileID,[sr4k_image_width,sr4k_image_height],'uint16');
c=fread(fileID,[sr4k_image_width,sr4k_image_height],'uint16');

fclose(fileID);


z=z';
x=x';
y=y';
img=img';
c=c';

% k=144*3+1;
% img = double(b(1:sr4k_image_height, :));
% z = a(1:144, :);   
% x = a(145:288, :);     
% y = a(289:144*3, :);
% z = medfilt2(z,[fw fw]);  x = medfilt2(x, [fw fw]);      y = medfilt2(y, [fw fw]); 

%time_stamp = a(721,1);  % time stamp
time_stamp=0;

% if confidence_read == 1
%     c = b(sr4k_image_height+1:sr4k_image_height*2, :);
%     %c = a(144*4+1:144*5, :);
%     % Apply median filter to a pixel which confidence leve is zero.
%     %confidence_cut_off = 1;
%     %[img, x, y, z, c] = compensate_badpixel(img, x, y, z, c, confidence_cut_off);
% else
%     c = 0;
% end

img_size=size(img);
x_size=size(x);
y_size=size(y);
z_size=size(z);
c_size=size(c);

if sum(img_size-sr4k_image_size)~=0 || sum(x_size-sr4k_image_size)~=0 || sum(y_size-sr4k_image_size)~=0 || sum(z_size-sr4k_image_size)~=0 || sum(c_size-sr4k_image_size)~=0
    %disp('One of matrix is corrupted.');
    error=-1;
    return;
end

%Cut-off on the horizontal boarder
if boarder_cut_off > 0
    img=cut_boarder(img,boarder_cut_off);
    x=cut_boarder(x,boarder_cut_off);
    y=cut_boarder(y,boarder_cut_off);
    z=cut_boarder(z,boarder_cut_off);
end

%Scale intensity image to [0 255]
if scale == 1
    img = scale_img(img, fw, type_value, 'intensity');
end

% % Adaptive histogram equalization
img = adapthisteq(img);
%img = histeq(img);


%filtering
%filter_list={'none','median','gaussian'};
gaussian_h = fspecial('gaussian',[3 3],1);  %sigma = 1
gaussian_h_5 = fspecial('gaussian',[5 5],1);  %sigma = 1
switch filter_name
    case 'median'
       img=medfilt2(img, [3 3]);
        x=medfilt2(x, [3 3]);
        y=medfilt2(y, [3 3]);
        z=medfilt2(z, [3 3]);
    case 'median5'
       img=medfilt2(img, [5 5]);
        x=medfilt2(x, [5 5]);
        y=medfilt2(y, [5 5]);
        z=medfilt2(z, [5 5]);    
    case 'gaussian'
        img=imfilter(img, gaussian_h,'replicate');
        x=imfilter(x, gaussian_h,'replicate');
        y=imfilter(y, gaussian_h,'replicate');
        z=imfilter(z, gaussian_h,'replicate');
    case 'gaussian_edge_std'
        img=imfilter(img, gaussian_h,'replicate');
        x_g=imfilter(x, gaussian_h,'replicate');
        y_g=imfilter(y, gaussian_h,'replicate');
        z_g=imfilter(z, gaussian_h,'replicate');
        x = check_edges(x, x_g);
        y = check_edges(y, y_g);
        z = check_edges(z, z_g);

    case 'gaussian5'
        img=imfilter(img, gaussian_h_5,'replicate');
        x=imfilter(x, gaussian_h_5,'replicate');
        y=imfilter(y, gaussian_h_5,'replicate');
        z=imfilter(z, gaussian_h_5,'replicate');
end


%rtime = etime(clock, t_pre); %cputime - t_pre;
%delete('d1_0001.bdat');

rtime = toc(t_pre);
end

function [img]=cut_boarder(img, cut_off)
    image_size=size(img);
    h_cut_off_pixel=round(image_size(2)*cut_off/100);
    v_cut_off_pixel=round(image_size(1)*cut_off/100);
    img(:,(image_size(2)-h_cut_off_pixel+1):image_size(2))=[];   %right side of Horizontal
    img(:,1:h_cut_off_pixel)=[];      %left side of Horizontal
    img((image_size(1)-v_cut_off_pixel+1):image_size(1),:)=[];   %up side of vertical
    img(1:v_cut_off_pixel,:)=[];      %bottom side of vertical
end

function [data] = check_edges(data, data_g)
%edges = 0; 

for i = 2:size(data,1)-1
    for j= 2:size(data,2)-1
        %if var(data(i-1:i+1,j-1:j+1)) <= 0.001
        unit_vector = [data(i-1,j-1:j+1) data(i, j-1:j+1) data(i+1, j-1:j+1)];
        %if std(unit_vector)/(max(unit_vector) - min(unit_vector)) <= 0.4
        if std(unit_vector) <= 0.1
            data(i,j) = data_g(i,j);
        %else
        %    edges = edges + 1;
        end
    end
end
%edges
end
