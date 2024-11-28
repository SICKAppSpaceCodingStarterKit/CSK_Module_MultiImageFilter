# Changelog
All notable changes to this project will be documented in this file.

## Release 2.0.0

### New features
- New filter to convert RGB to Lab channels
- Supports FlowConfig feature to set images / transformation to process / provide processed image
- Position to crop image can be received by external event
- Provide version of module via 'OnNewStatusModuleVersion'
- Function 'getParameters' to provide PersistentData parameters
- Check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function
- Function to 'resetModule' to default setup

### Improvements
- New UI design available (e.g. selectable via CSK_Module_PersistentData v4.1.0 or higher), see 'OnNewStatusCSKStyle'
- check if instance exists if selected
- 'loadParameters' returns its success
- 'sendParameters' can control if sent data should be saved directly by CSK_Module_PersistentData
- Added UI icon and browser tab information
- Info in UI if image type does not fit to canny or blur filter

### Bugfix
- Error if module is not active but 'getInstancesAmount' was called
- processInstanceNUM did not work after deregistering from event to process images

## Release 1.0.0
- Initial commit