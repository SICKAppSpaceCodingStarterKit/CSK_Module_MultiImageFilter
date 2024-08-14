--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('ImageProcessing.MultiImageFilter.FlowConfig.MultiImageFilter_ImageSource')
require('ImageProcessing.MultiImageFilter.FlowConfig.MultiImageFilter_OnNewImage')
require('ImageProcessing.MultiImageFilter.FlowConfig.MultiImageFilter_Process')

-- Reference to the multiImageFilter_Instances handle
local multiImageFilter_Instances

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    for i = 1, #multiImageFilter_Instances do
      if multiImageFilter_Instances[i].parameters.flowConfigPriority then
        CSK_MultiImageFilter.clearFlowConfigRelevantConfiguration()
        break
      end
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)

--- Function to get access to the multiImageFilter_Instances
---@param handle handle Handle of multiImageFilter_Instances object
local function setMultiImageFilter_Instances_Handle(handle)
  multiImageFilter_Instances = handle
end

return setMultiImageFilter_Instances_Handle