function [PDS ,c ,s] = joypress_init(PDS ,c ,s)
% initialization function
% this is executed only 1 time, after the settings file is read in,
% as part of the 'Initialize' action from the GUI
% This is where values are defined for the entire experiment

% Lab configuation parameters
c.viewdist                                      = 410;   % viewing distance (mm)
c.screenhpix                                    = 1200;  % screen height (pixels)
c.screenh                                       = 302.40; % screen height (mm)

% initialize color lookup tables
% CLUTs may be customized as needed
% CLUTS also need to be defined before initializing DataPixx
c.humanCLUT                                     = c.humanColors;
c.monkeyCLUT                                    = c.monkeyColors;
c.humanCLUT(length(c.humanColors)+1:256,:)      = zeros(256-length(c.humanColors),3);
c.monkeyCLUT(length(c.monkeyColors)+1:256,:)    = zeros(256-length(c.monkeyColors),3);
%% Initalize audio
% must be done prior to initalizing datapix, where the waveforms are loaded
% into memory
c = init_audio(c);

% initialize DataPixx
[c] = init_DataPixx(c);

% get trial codes:
[c.triallist1_init, c.triallist2_init, c.triallist3_init, c.trialtype_values, c.trialtype_names]=get_trialcodes;
c.triallist1_tbd=c.triallist1_init;% list of pointers to the trial types in trialtypes.m
c.triallist2_tbd=c.triallist2_init;
c.triallist3_tbd=c.triallist3_init;

% do other one-time initialization steps as desired
c.middleXY                                      = c.screenRect([3 4])/2; % center of the display

% open a plotting window
% c.pfh1                                          =  figure('Position',[0 0 1000 500],'Name',['JoyPress Duration Data (' date ')']);


