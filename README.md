Read ISS-LIS

DOI: https://doi.org/10.1175/JTECH-D-18-0173.1.

Installation
read_LIS_pub.m requires installation of Matlab.

Description
This code reads ISS-LIS QC L2 files and save them as .mat files. 
The files include 3 data products: event, group and flash.

- Event level parameters
Orbit# Year Month Day Hour Minute Second Millisecond Obs_time Lat Lon Radiance Footprint Address ParentAdd X_pixel Y_pixel RawBg CalBg RawAmp Sza Glint Threshold AlertFg ClusterIndx DensityIndx NoiseIndx BgFg

- Group level parameters
Orbit# Year Month Day Hour Minute Second Millisecond Obs_time Lat Lon Radiance Footprint Address ParentAdd ChildAdd ChildCount Threshold Alert ClusterIndx DensityIndx NoiseIndx Glint Eccentricity

- Flash level parameters
Orbit# Year Month Day Hour Minute Second Millisecond Duration Obs_time Lat Lon Radiance Footprint Address ParentAdd ChildAdd ChildCount GrandchildCount Threshold Alert

For more details about the ISS-LIS instrument and data structure, see https://ghrc.nsstc.nasa.gov/lightning/data/data_lis_iss.html.
