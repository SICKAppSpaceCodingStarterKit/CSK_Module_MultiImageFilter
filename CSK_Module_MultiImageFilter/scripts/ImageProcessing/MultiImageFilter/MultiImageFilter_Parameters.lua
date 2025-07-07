---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local multiImageFilterParameters = {}
  multiImageFilterParameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  multiImageFilterParameters.registeredEvent = '' -- If thread internal function should react on external event, define it here, e.g. 'CSK_OtherModule.OnNewInput'
  multiImageFilterParameters.processingFile = 'CSK_MultiImageFilter_Processing' -- which file to use for processing (will be started in own thread)
  multiImageFilterParameters.filterType = 'Gray' -- Type of filter to use

  multiImageFilterParameters.labChannel = 'L' -- Channel to use if images was converted to Lab channels, 'L', 'a' or 'b'

  multiImageFilterParameters.cannyThresholdHigh = 255 --100 -- First/high threshold to find strong edges
  multiImageFilterParameters.cannyThresholdLow = 10 --50 -- Second/low threshold for finding weaker edges connected with the strong edges

  multiImageFilterParameters.blurKernelSizePix = 15 -- Size of the kernel

  multiImageFilterParameters.cropPositionSource = 'MANUAL' -- 'MANUAL' or 'EXTERNAL' source for cropping
  multiImageFilterParameters.cropPosX = 267 -- The x position of the top-left corner of the cropped image in the source image (MANUAL MODE)
  multiImageFilterParameters.cropPosY = 200 -- The y position of the top-left corner of the cropped image in the source image (MANUAL MODE)
  multiImageFilterParameters.cropWidth = 150 -- The width of the cropped image
  multiImageFilterParameters.cropHeight = 80 -- The height  of the cropped image
  multiImageFilterParameters.registeredCropPositionEvent = '' -- If thread internal function should react on external transformation event, define it here, e.g. 'CSK_OtherModule.OnNewTransformation'

  multiImageFilterParameters.transformationSource = 'MANUAL' -- 'MANUAL' or 'EXTERNAL' source for transformation
  multiImageFilterParameters.transX = 0 -- Manual transformation in x direction
  multiImageFilterParameters.transY = 0 -- Manual transformation in y direction
  multiImageFilterParameters.transAngle = 0 -- Manual angle transformation
  multiImageFilterParameters.transAngleOriginX = 0 -- X origin for manual angle transformation
  multiImageFilterParameters.transAngleOriginY = 0 -- Y origin for manual angle transformation
  multiImageFilterParameters.registeredTransformationEvent = '' -- If thread internal function should react on external transformation event, define it here, e.g. 'CSK_OtherModule.OnNewTransformation'

  multiImageFilterParameters.showImage = false -- Show image in UI

  return multiImageFilterParameters
end
functions.getParameters = getParameters

return functions