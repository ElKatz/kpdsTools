# kpds_tools 
Temporary repo for all things krauzlis pldaps related.

### actions
Krauzlis pldaps (`pldaps_gui2.m`) has a number of "actions" that may be issued from the gui.

This repo has a number of actions one may download and integrate into their rig setup. 
In order to add an action, go to the settings file (e.g. `joypress_settings.m`) and add the action mfile. For example:
```Matlab
m.action_5 = 'calibrate_eyelink.m'
```

### analysis
Scripts for analysis of behavioral data. TBD. 
