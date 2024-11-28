---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_MultiImageFilter'

-- Create kind of "class"
local multiImageFilter = {}
multiImageFilter.__index = multiImageFilter

multiImageFilter.styleForUI = 'None' -- Optional parameter to set UI style
multiImageFilter.version = Engine.getCurrentAppVersion() -- Version of module

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  multiImageFilter.styleForUI = theme
  Script.notifyEvent("MultiImageFilter_OnNewStatusCSKStyle", multiImageFilter.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--- Function to create new instance
---@param multiImageFilterInstanceNo int Number of instance
---@return table[] self Instance of multiImageFilter
function multiImageFilter.create(multiImageFilterInstanceNo)

  local self = {}
  setmetatable(self, multiImageFilter)

  self.multiImageFilterInstanceNo = multiImageFilterInstanceNo -- Number of this instance
  self.multiImageFilterInstanceNoString = tostring(self.multiImageFilterInstanceNo) -- Number of this instance as string
  self.helperFuncs = require('ImageProcessing/MultiImageFilter/helper/funcs') -- Load helper functions

  -- Create parameters etc. for this module instance
  self.activeInUI = false -- Check if this instance is currently active in UI

  -- Check if CSK_PersistentData module can be used if wanted
  self.persistentModuleAvailable = CSK_PersistentData ~= nil or false

  -- Check if CSK_UserManagement module can be used if wanted
  self.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

  -- Default values for persistent data
  -- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
  self.parametersName = 'CSK_MultiImageFilter_Parameter' .. self.multiImageFilterInstanceNoString -- name of parameter dataset to be used for this module
  self.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  self.parameters.registeredEvent = '' -- If thread internal function should react on external event, define it here, e.g. 'CSK_OtherModule.OnNewInput'
  self.parameters.processingFile = 'CSK_MultiImageFilter_Processing' -- which file to use for processing (will be started in own thread)
  self.parameters.filterType = 'Gray' -- Type of filter to use

  self.parameters.labChannel = 'L' -- Channel to use if images was converted to Lab channels, 'L', 'a' or 'b'

  self.parameters.cannyThresholdHigh = 255 --100 -- First/high threshold to find strong edges
  self.parameters.cannyThresholdLow = 10 --50 -- Second/low threshold for finding weaker edges connected with the strong edges

  self.parameters.blurKernelSizePix = 15 -- Size of the kernel

  self.parameters.cropPositionSource = 'MANUAL' -- 'MANUAL' or 'EXTERNAL' source for cropping
  self.parameters.cropPosX = 267 -- The x position of the top-left corner of the cropped image in the source image (MANUAL MODE)
  self.parameters.cropPosY = 200 -- The y position of the top-left corner of the cropped image in the source image (MANUAL MODE)
  self.parameters.cropWidth = 150 -- The width of the cropped image
  self.parameters.cropHeight = 80 -- The height  of the cropped image
  self.parameters.registeredCropPositionEvent = '' -- If thread internal function should react on external transformation event, define it here, e.g. 'CSK_OtherModule.OnNewTransformation'

  self.parameters.transformationSource = 'MANUAL' -- 'MANUAL' or 'EXTERNAL' source for transformation
  self.parameters.transX = 0 -- Manual transformation in x direction
  self.parameters.transY = 0 -- Manual transformation in y direction
  self.parameters.transAngle = 0 -- Manual angle transformation
  self.parameters.transAngleOriginX = 0 -- X origin for manual angle transformation
  self.parameters.transAngleOriginY = 0 -- Y origin for manual angle transformation
  self.parameters.registeredTransformationEvent = '' -- If thread internal function should react on external transformation event, define it here, e.g. 'CSK_OtherModule.OnNewTransformation'

  self.parameters.showImage = false -- Show image in UI

  -- Parameters to give to the processing script
  self.multiImageFilterProcessingParams = Container.create()
  self.multiImageFilterProcessingParams:add('multiImageFilterInstanceNumber', multiImageFilterInstanceNo, "INT")
  self.multiImageFilterProcessingParams:add('registeredEvent', self.parameters.registeredEvent, "STRING")

  self.multiImageFilterProcessingParams:add('showImage', self.parameters.showImage, "BOOL")
  self.multiImageFilterProcessingParams:add('viewerId', 'multiImageFilterViewer' .. self.multiImageFilterInstanceNoString, "STRING")

  self.multiImageFilterProcessingParams:add('filterType', self.parameters.filterType, "STRING")

  self.multiImageFilterProcessingParams:add('labChannel', self.parameters.labChannel, "STRING")

  self.multiImageFilterProcessingParams:add('blurKernelSizePix', self.parameters.blurKernelSizePix, "INT")

  self.multiImageFilterProcessingParams:add('cannyThresholdLow', self.parameters.cannyThresholdLow, "INT")
  self.multiImageFilterProcessingParams:add('cannyThresholdHigh', self.parameters.cannyThresholdHigh, "INT")

  self.multiImageFilterProcessingParams:add('cropPositionSource', self.parameters.cropPositionSource, "STRING")
  self.multiImageFilterProcessingParams:add('cropPosX', self.parameters.cropPosX, "INT")
  self.multiImageFilterProcessingParams:add('cropPosY', self.parameters.cropPosY, "INT")
  self.multiImageFilterProcessingParams:add('cropWidth', self.parameters.cropWidth, "INT")
  self.multiImageFilterProcessingParams:add('cropHeight', self.parameters.cropHeight, "INT")
  self.multiImageFilterProcessingParams:add('registeredCropPositionEvent', self.parameters.registeredCropPositionEvent, "STRING")

  self.multiImageFilterProcessingParams:add('transformationSource', self.parameters.transformationSource, "STRING")
  self.multiImageFilterProcessingParams:add('transX', self.parameters.transX, "INT")
  self.multiImageFilterProcessingParams:add('transY', self.parameters.transY, "INT")
  self.multiImageFilterProcessingParams:add('transAngle', self.parameters.transAngle, "INT")
  self.multiImageFilterProcessingParams:add('transAngleOriginX', self.parameters.transAngleOriginX, "INT")
  self.multiImageFilterProcessingParams:add('transAngleOriginY', self.parameters.transAngleOriginY, "INT")
  self.multiImageFilterProcessingParams:add('registeredTransformationEvent', self.parameters.registeredTransformationEvent, "STRING")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiImageFilterProcessingParams)

  return self
end

--[[
--- Some internal code docu for local used function to do something
function multiImageFilter:doSomething()
  self.object:doSomething()
end

--- Some internal code docu for local used function to do something else
function multiImageFilter:doSomethingElse()
  self:doSomething() --> access internal function
end
]]

return multiImageFilter

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************