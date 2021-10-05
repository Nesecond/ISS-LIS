clear all;close all;clc;

%% This code is to read ISS-LIS QC L2 files and save them as .mat files
%Modified on 04/06/2020 by Daile Zhang (dlzhang@umd.edu)
%For publication acknowledgement, please include Daile Zhang from the
%University of Maryland.

%%-------------------------------------------------------------------------
%%Read LIS daily files
%%Event level parameters
%Orbit# Year Month Day Hour Minute Second Millisecond Obs_time Lat Lon Radiance ...
%Footprint Address ParentAdd X_pixel Y_pixel RawBg CalBg RawAmp Sza Glint
%Threshold AlertFg ClusterIndx DensityIndx NoiseIndx BgFg

%%Group level parameters
%Orbit# Year Month Day Hour Minute Second Millisecond Obs_time Lat Lon Radiance ...
%Footprint Address ParentAdd ChildAdd ChildCount Threshold Alert
%ClusterIndx DensityIndx NoiseIndx Glint Eccentricity

%%Flash level parameters
%Orbit# Year Month Day Hour Minute Second Millisecond Duration Obs_time Lat Lon ...
%Radiance Footprint Address ParentAdd ChildAdd ChildCount GrandchildCount Threshold Alert

%--------------------------------------------------------------------------
%Data folder should be daily basis

% Get a list of all files and folders in this folder.
files = dir('...\ISS LIS\data\');
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags);
subFolders = subFolders(3:end,:);

for i_folder=1:size(subFolders,1)-1
    clear datapath filedir;
    clear EEtime Etime event event_add event_alert event_amplitude event_bg_flag...
        event_bg_rad event_bg_value event_cluster_index event_data_event_density_index...
        event_data event_density_index event_endtime event_fp event_glint_index...
        event_lat event_lon event_noise_index event_obstime event_parent_id...
        event_rad event_starttime event_sza_index event_threshold event_time...
        event_x event_y;
    clear fftime flash flash_add flash_alert flash_child_count flash_child_id...
        flash_cluster_index flash_data flash_density_index flash_duration flash_endtime...
        flash_fp flash_glint flash_grandchild_count flash_lat flash_lon...
        flash_noise_index flash_oblong flash_obstime flash_parent_id flash_rad...
        flash_starttime flash_threshold flash_time ftime;
    clear ggtime group group_add group_alert group_child_count group_child_id...
        group_cluster_index group_data group_density_index group_endtime group_fp...
        group_glint_index group_lat group_lon group_noise_index group_oblong_index...
        group_obstime group_parent_id group_rad group_starttime group_threshold...
        group_time gtime;
    clear i itrue j n_event n_flash n_group nFiles S SNumb;
    
    datapath=strcat('...\ISS LIS\data\',subFolders(i_folder).name,'\');
    
    filedir=dir(strcat(datapath,'*.hdf'));
    
    %File list
    dataFileList={filedir.name};
        
    %Length fo the filelist
    nFiles=length(dataFileList);
    
    %Leap second
    leap_second=10;
    %For leap second information, look up how many leap seconds from
    %1993-01-01 at https://en.wikipedia.org/wiki/Leap_second. 
    
    for i=1:nFiles
        FileName=cell2mat(dataFileList(i));
        FileName=strcat(datapath,FileName);
        
        S = hdfinfo(FileName);
        SNumb = S.Vgroup.Vgroup.Vgroup.Vdata.NumRecords;
        
        if SNumb>0 %to make sure there is data in the overpass
            itrue(i)=i;
            
            
            %lightning info
            flash{i}=hdfread(FileName,'flash');
            group{i}=hdfread(FileName,'group');
            event{i}=hdfread(FileName,'event');
            
            %event info
            %2ms
            event_time{i,:}=event{1,i}{1};
            event_obstime{i,:}=event{1,i}{2};%observational time
            event_lat{i,:}=event{1,i}{3}(1,:);
            event_lon{i,:}=event{1,i}{3}(2,:);
            event_rad{i,:}=event{1,i}{4}; %Calibrated event radiance
            event_fp{i,:}=event{1,i}{5}; %Size of event (km2)
            event_add{i,:}=event{1,i}{6}; %HDF address of event
            event_parent_id{i,:}=event{1,i}{7}; %Parent group HDF address
            event_x{i,:}=event{1,i}{8}; %x pixel location
            event_y{i,:}=event{1,i}{9}; %y pixel location
            event_bg_value{i,:}=event{1,i}{10}; %Estimated raw background value ...
            % Level of background illumination (16-bit) at time of the event
            event_bg_rad{i,:}=event{1,i}{11}; %Estimated calibrated background value ...
            % uJ/sr/m²/um
            event_amplitude{i,:}=event{1,i}{12}; %Uncalibrated optical amplitude ...
            % reported by instrument (a 7-bit digital count)
            event_sza_index{i,:}=event{1,i}{13}; %Event solar zenith angle
            event_glint_index{i,:}=event{1,i}{14}; %Event glint angle
            event_threshold{i,:}=event{1,i}{15}; %Estimated threshold
            event_alert{i,:}=event{1,i}{16}; %LIS/TRMM alert flags status
            event_cluster_index{i,:}=event{1,i}{17}; %Pixel density metric ...
            % higher numbers indicate area is less likely to be noise (byte)
            event_density_index{i,:}=event{1,i}{18}; %Spatial density metric ...
            % higher if area geolocated in a region of high lightning activity
            % (byte)
            event_noise_index{i,:}=event{1,i}{19}; %Signal-to-signal plus noise ratio
            event_bg_flag{i,:}=event{1,i}{20}; % Bg radiance has been ...
            % 0: estimated from sza
            % 1: interpolated from bgs
            
            
            %group info
            group_time{i,:}=group{1,i}{1}; %TAI start time of the group
            group_obstime{i,:}=group{1,i}{2}; %observational time
            group_lat{i,:}=group{1,i}{3}(1,:);
            group_lon{i,:}=group{1,i}{3}(2,:);
            group_rad{i,:}=group{1,i}{4}; %Total radiance of the group
            group_fp{i,:}=group{1,i}{5};
            group_add{i,:}=group{1,i}{6}; %HDF address of group
            group_parent_id{i,:}=group{1,i}{7};
            group_child_id{i,:}=group{1,i}{8}; %HDF address of first child event
            group_child_count{i,:}=group{1,i}{9}; %# of child events
            group_threshold{i,:}=group{1,i}{10}; %LIS threshold during group
            group_alert{i,:}=group{1,i}{11}; %LIS/TRMM status during group
            group_cluster_index{i,:}=group{1,i}{12}; %Pixel density metric ...
            % higher numbers indicate group is less likely to be noise(byte)
            group_density_index{i,:}=group{1,i}{13}; %Spatial density metric ...
            % higher if - group geolocated in a region of high lightning
            % activity (byte)
            group_noise_index{i,:}=group{1,i}{14}; %Signal-to-signal plus noise ratio
            group_glint_index{i,:}=group{1,i}{15}; %Group solar glint cosine angle (degrees)
            group_oblong_index{i,:}=group{1,i}{16}; % Eccentricity of the group
            
            
            %flash info
            %within 330ms & 5.5km
            flash_time{i,:}=flash{1,i}{1}; %TAI start time of the flash
            flash_duration{i,:}=flash{1,i}{2}; %Time between first and last event
            flash_obstime{i,:}=flash{1,i}{3}; %Observational time
            flash_lat{i,:}=flash{1,i}{4}(1,:);
            flash_lon{i,:}=flash{1,i}{4}(2,:);
            flash_rad{i,:}=flash{1,i}{5}; %Total radiance of the flash
            flash_fp{i,:}=flash{1,i}{6};
            flash_add{i,:}=flash{1,i}{7}; %HDF address of flash
            flash_parent_id{i,:}=flash{1,i}{8};
            flash_child_id{i,:}=flash{1,i}{9};
            flash_child_count{i,:}=flash{1,i}{10};
            flash_grandchild_count{i,:}=flash{1,i}{11};
            flash_threshold{i,:}=flash{1,i}{12}; %LIS threshold during flash
            flash_alert{i,:}=flash{1,i}{13}; %LIS/TRMM status during flash
            flash_cluster_index{i,:}=flash{1,i}{14};%Pixel density metric ...
            % higher numbers indicate flash is less likely to be noise
            flash_density_index{i,:}=flash{1,i}{15};%Spatial density metric...
            % higher if flash geolocated in a region of high lightning activity
            flash_noise_index{i,:}=flash{1,i}{16};%Signal-to-signal plus noise ratio
            flash_glint{i,:}=flash{1,i}{17};%Flash solar glint cosine angle (degrees)
            flash_oblong{i,:}=flash{1,i}{18};%Eccentricity of the flash
            
        else itrue(i)=0;
            
        end
        
    end
    clear i;
    
    %Consider the leap-second
    for i=1:length(group_time)
        
        if itrue(i)~=0
            event_starttime{i}=datestr(floor(event_time{i,1}(1)-leap_second)/86400 + datenum('1993-01-01 00:00:00'),'yyyy-mm-dd HH:MM:SS');
            event_endtime{i}=datestr(floor(event_time{i,1}(end)-leap_second)/86400 + datenum('1993-01-01 00:00:00'),'yyyy-mm-dd HH:MM:SS');
            
            group_starttime{i}=datestr(floor(group_time{i,1}(1)-leap_second)/86400 + datenum('1993-01-01 00:00:00'),'yyyy-mm-dd HH:MM:SS');
            group_endtime{i}=datestr(floor(group_time{i,1}(end)-leap_second)/86400 + datenum('1993-01-01 00:00:00'),'yyyy-mm-dd HH:MM:SS');
            
            flash_starttime{i}=datestr(floor(flash_time{i,1}(1)-leap_second)/86400 + datenum('1993-01-01 00:00:00'),'yyyy-mm-dd HH:MM:SS');
            flash_endtime{i}=datestr(floor(flash_time{i,1}(end)-leap_second)/86400 + datenum('1993-01-01 00:00:00'),'yyyy-mm-dd HH:MM:SS');
            
        end
    end
    clear i;
    
    
    n_event=1;n_group=1;n_flash=1;
    
    event_data=[];
    
    for i=1:length(event)
        if itrue(i)~=0
            for j=1:length(event{1,i}{1,1})
                event_data(n_event,1)=i;
                event_data(n_event,2)=event_obstime{i,1}(j);
                event_data(n_event,3)=event_time{i,1}(j);
                event_data(n_event,4)=event_lat{i,1}(j);
                event_data(n_event,5)=event_lon{i,1}(j);
                event_data(n_event,6)=event_rad{i,1}(j);
                event_data(n_event,7)=event_fp{i,1}(j);
                event_data(n_event,8)=event_add{i,1}(j);
                event_data(n_event,9)=event_parent_id{i,1}(j);
                event_data(n_event,10)=event_x{i,1}(j);
                event_data(n_event,11)=event_y{i,1}(j);
                event_data(n_event,12)=event_bg_value{i,1}(j);
                event_data(n_event,13)=event_bg_rad{i,1}(j);
                event_data(n_event,14)=event_amplitude{i,1}(j);
                event_data(n_event,15)=event_sza_index{i,1}(j);
                event_data(n_event,16)=event_glint_index{i,1}(j);
                event_data(n_event,17)=event_threshold{i,1}(j);
                event_data(n_event,18)=event_alert{i,1}(j);
                event_data(n_event,19)=event_cluster_index{i,1}(j);
                event_data(n_event,20)=event_density_index{i,1}(j);
                event_data(n_event,21)=event_noise_index{i,1}(j);
                event_data(n_event,22)=event_bg_flag{i,1}(j);
                
                n_event=n_event+1;
            end
        end
    end
    clear i j;
    
    
    while ~isempty(event_data)
        Etime=datestr((event_data(:,3)-leap_second)/86400 + ...
            datenum('1993-01-01 00:00:00.000'),'yyyy-mm-dd HH:MM:SS.FFF');
        EEtime(:,1)=str2num(Etime(:,1:4));
        EEtime(:,2)=str2num(Etime(:,6:7));
        EEtime(:,3)=str2num(Etime(:,9:10));
        EEtime(:,4)=str2num(Etime(:,12:13));
        EEtime(:,5)=str2num(Etime(:,15:16));
        EEtime(:,6)=str2num(Etime(:,18:19));
        EEtime(:,7)=str2num(Etime(:,21:23));
        
        event_data=[event_data(:,1) EEtime event_data(:,3:22)];
        break;
    end
    
    
    group_data=[];
    
    for i=1:length(group)
        if itrue(i)~=0
            for j=1:length(group{1,i}{1,1})
                group_data(n_group,1)=i;
                group_data(n_group,2)=group_time{i,1}(j);
                group_data(n_group,3)=group_obstime{i,1}(j);
                group_data(n_group,4)=group_lat{i,1}(j);
                group_data(n_group,5)=group_lon{i,1}(j);
                group_data(n_group,6)=group_rad{i,1}(j);
                group_data(n_group,7)=group_fp{i,1}(j);
                group_data(n_group,8)=group_add{i,1}(j);
                group_data(n_group,9)=group_parent_id{i,1}(j);
                group_data(n_group,10)=group_child_id{i,1}(j);
                group_data(n_group,11)=group_child_count{i,1}(j);
                group_data(n_group,12)=group_threshold{i,1}(j);
                group_data(n_group,13)=group_alert{i,1}(j);
                group_data(n_group,14)=group_cluster_index{i,1}(j);
                group_data(n_group,15)=group_density_index{i,1}(j);
                group_data(n_group,16)=group_noise_index{i,1}(j);
                group_data(n_group,17)=group_glint_index{i,1}(j);
                group_data(n_group,18)=group_oblong_index{i,1}(j);
                
                n_group=n_group+1;
            end
        end
    end
    clear i j;
    
    
    while ~isempty(group_data)
        gtime=datestr((group_data(:,2)-leap_second)/86400 + ...
            datenum('1993-01-01 00:00:00.000'),'yyyy-mm-dd HH:MM:SS.FFF');
        ggtime(:,1)=str2num(gtime(:,1:4));
        ggtime(:,2)=str2num(gtime(:,6:7));
        ggtime(:,3)=str2num(gtime(:,9:10));
        ggtime(:,4)=str2num(gtime(:,12:13));
        ggtime(:,5)=str2num(gtime(:,15:16));
        ggtime(:,6)=str2num(gtime(:,18:19));
        ggtime(:,7)=str2num(gtime(:,21:23));
        
        group_data=[group_data(:,1) ggtime group_data(:,3:18)];
        break;
    end
    
    
    flash_data=[];
    
    for i=1:length(flash)
        if itrue(i)~=0
            for j=1:length(flash{1,i}{1,1})
                flash_data(n_flash,1)=i;
                flash_data(n_flash,2)=flash_time{i,1}(j);
                flash_data(n_flash,3)=flash_duration{i,1}(j);
                flash_data(n_flash,4)=flash_obstime{i,1}(j);
                flash_data(n_flash,5)=flash_lat{i,1}(j);
                flash_data(n_flash,6)=flash_lon{i,1}(j);
                flash_data(n_flash,7)=flash_rad{i,1}(j);
                flash_data(n_flash,8)=flash_fp{i,1}(j);
                flash_data(n_flash,9)=flash_add{i,1}(j);
                flash_data(n_flash,10)=flash_parent_id{i,1}(j);
                flash_data(n_flash,11)=flash_child_id{i,1}(j);
                flash_data(n_flash,12)=flash_child_count{i,1}(j);
                flash_data(n_flash,13)=flash_grandchild_count{i,1}(j);
                flash_data(n_flash,14)=flash_threshold{i,1}(j);
                flash_data(n_flash,15)=flash_alert{i,1}(j);
                flash_data(n_flash,16)=flash_cluster_index{i,1}(j);
                flash_data(n_flash,17)=flash_density_index{i,1}(j);
                flash_data(n_flash,18)=flash_noise_index{i,1}(j);
                flash_data(n_flash,19)=flash_glint{i,1}(j);
                flash_data(n_flash,20)=flash_oblong{i,1}(j);
                
                n_flash=n_flash+1;
            end
        end
    end
    
    
    while ~isempty(flash_data)
        ftime=datestr((flash_data(:,2)-leap_second)/86400 + ...
            datenum('1993-01-01 00:00:00.000'),'yyyy-mm-dd HH:MM:SS.FFF');
        fftime(:,1)=str2num(ftime(:,1:4));
        fftime(:,2)=str2num(ftime(:,6:7));
        fftime(:,3)=str2num(ftime(:,9:10));
        fftime(:,4)=str2num(ftime(:,12:13));
        fftime(:,5)=str2num(ftime(:,15:16));
        fftime(:,6)=str2num(ftime(:,18:19));
        fftime(:,7)=str2num(ftime(:,21:23));
        
        flash_data=[flash_data(:,1) fftime flash_data(:,3:20)];
        break;
    end
    
        savepath='..\ISS LIS\save\'; %save data path
    
    save(strcat(savepath,'event_data_',subFolders(1).folder(end-3:end),...
        subFolders(i_folder).name,'.mat'),'event_data');
    save(strcat(savepath,'group_data_',subFolders(1).folder(end-3:end),...
        subFolders(i_folder).name,'.mat'),'group_data');
    save(strcat(savepath,'flash_data_',subFolders(1).folder(end-3:end),...
        subFolders(i_folder).name,'.mat'),'flash_data');

end
clear i_folder;




