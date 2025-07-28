--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('ImageProcessing.MultiImageFilter.FlowConfig.MultiImageFilter_ImageSource')
require('ImageProcessing.MultiImageFilter.FlowConfig.MultiImageFilter_OnNewImage')
require('ImageProcessing.MultiImageFilter.FlowConfig.MultiImageFilter_Process')

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    CSK_MultiImageFilter.clearFlowConfigRelevantConfiguration()
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
