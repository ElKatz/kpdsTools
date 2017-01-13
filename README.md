# kpds_tools 
A (temporary) repo for user-friendly backwards-compatible modular add-ons to the krauzlis lab pldaps (abbreviated "kpds").
I porpose a slightly different folder organization and provide code that should work pretty neatly with either this (or the previous) organziation.

## Folder organization, a suggestion:
A project typically includes a number of tasks. Each taks gets a folder. In each task folder (with task name "`*`") we'll have the 5 core task-related mfiles: `*_init.m, *_run.m, *_finish.m, *_next.m, and *_settings`. In addition, an "Actions" folder with actions that may be executed directly from the gui, a "Data" folder with pldaps data, and a "Figures" fodler with any figure that may be saved out (typically via an action). Each project needs a separate `pldaps_gui2.m` file:
```
Project_name 
  pldaps_gui2.m
  Task_1    (e.g. memory-guided saccade)
    *_init.m, *_run.m, *_finish.m, *_next.m, *_settings
    Actions
    Data
    Figures
  Task_2    (e.g. BL, FA, singlePA, doublePA attention task)
    *_init.m, *_run.m, *_finish.m, *_next.m, *_settings
    Actions
    Data
    Figures
  ...
```


## actions
Actions may be executed directly from the GUI (`pldaps_gui2.m`).

This repo has a number of actions that may be download and directly integrated. In order to add an action to your GUI, go to the settings file (e.g. `joypress_settings.m`) and add the action mfile. For example:
```Matlab
m.action_5 = 'calibrate_eyelink.m'
```

## analysis
Scripts for analysis of behavioral data. TBD. 

## tasks
Bare bones tasks e.g. memory-guided saccade.






    

