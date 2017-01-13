# kpds_tools 
Temporary repo for all things krauzlis pldaps related.

## actions
Krauzlis pldaps (`pldaps_gui2.m`) has a number of "actions" that may be issued from the gui.

This repo has a number of actions one may download and integrate into their rig setup. 
In order to add an action, go to the settings file (e.g. `joypress_settings.m`) and add the action mfile. For example:
```Matlab
m.action_5 = 'calibrate_eyelink.m'
```

## analysis
Scripts for analysis of behavioral data. TBD. 

## tasks
Bare bones tasks e.g. memory-guided saccade.



### My 2 cents on folder organization (this is a work in progress)
(Not advocating, just suggesting..)
The basic idea is that every project includes a number of tasks. Each taks gets a folder. In each task folder we'll have associateed actions, a folder for saved data, and a folder for saved figures. Here's the structure:
```
Project_name 
  Task_1    (e.g. memory-guided saccade)
    Actions
    Data
    Figures
  Task_2    (e.g. BL, FA, singlePA, doublePA attention task)
    Actions
    Data
    Figures
  ...
```


    

