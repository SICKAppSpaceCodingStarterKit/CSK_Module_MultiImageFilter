---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the MultiImageFilter_Model and _Instances
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_MultiImageFilter'

local funcs = {}

-- Timer to update UI via events after page was loaded
local tmrMultiImageFilter = Timer.create()
tmrMultiImageFilter:setExpirationTime(300)
tmrMultiImageFilter:setPeriodic(false)

-- Timer to hide UI message after 2 seconds
local tmrUIMessage = Timer.create()
tmrUIMessage:setExpirationTime(5000)
tmrUIMessage:setPeriodic(false)

local multiImageFilter_Model -- Reference to model handle
local multiImageFilter_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('ImageProcessing/MultiImageFilter/helper/funcs')

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiImageFilter.processInstanceNUM", emptyFunction)

Script.serveEvent("CSK_MultiImageFilter.OnNewImageNUM", "MultiImageFilter_OnNewImageNUM")
Script.serveEvent("CSK_MultiImageFilter.OnNewValueToForwardNUM", "MultiImageFilter_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiImageFilter.OnNewValueUpdateNUM", "MultiImageFilter_OnNewValueUpdateNUM")

----------------------------------------------------------------

-- Real events
--------------------------------------------------

Script.serveEvent('CSK_MultiImageFilter.OnNewStatusModuleVersion', 'MultiImageFilter_OnNewStatusModuleVersion')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusCSKStyle', 'MultiImageFilter_OnNewStatusCSKStyle')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusModuleIsActive', 'MultiImageFilter_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_MultiImageFilter.OnNewStatusUIMessage', 'MultiImageFilter_OnNewStatusUIMessage')

Script.serveEvent('CSK_MultiImageFilter.OnNewResult', 'MultiImageFilter_OnNewResult')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusFoundMatches', 'MultiImageFilter_OnNewStatusFoundMatches')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusMatchScoreResult', 'MultiImageFilter_OnNewStatusMatchScoreResult')

Script.serveEvent("CSK_MultiImageFilter.OnNewViewerID", "MultiImageFilter_OnNewViewerID")
Script.serveEvent("CSK_MultiImageFilter.OnNewStatusShowImage", "MultiImageFilter_OnNewStatusShowImage")
Script.serveEvent("CSK_MultiImageFilter.OnNewStatusRegisteredEvent", "MultiImageFilter_OnNewStatusRegisteredEvent")

Script.serveEvent('CSK_MultiImageFilter.OnNewStatusImageFilterType', 'MultiImageFilter_OnNewStatusImageFilterType')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusBlurKernelSizePix', 'MultiImageFilter_OnNewStatusBlurKernelSizePix')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusCannyThresholds', 'MultiImageFilter_OnNewStatusCannyThresholds')

Script.serveEvent('CSK_MultiImageFilter.OnNewStatusLabChannel', 'MultiImageFilter_OnNewStatusLabChannel')

Script.serveEvent('CSK_MultiImageFilter.OnNewStatusCropPositionSource', 'MultiImageFilter_OnNewStatusCropPositionSource')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusCropPosX', 'MultiImageFilter_OnNewStatusCropPosX')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusCropPosY', 'MultiImageFilter_OnNewStatusCropPosY')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusCropWidth', 'MultiImageFilter_OnNewStatusCropWidth')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusCropHeight', 'MultiImageFilter_OnNewStatusCropHeight')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusRegisteredCropPositionEvent', 'MultiImageFilter_OnNewStatusRegisteredCropPositionEvent')

Script.serveEvent('CSK_MultiImageFilter.OnNewStatusTransformationSource', 'MultiImageFilter_OnNewStatusTransformationSource')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusTransformationX', 'MultiImageFilter_OnNewStatusTransformationX')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusTransformationY', 'MultiImageFilter_OnNewStatusTransformationY')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusTransformationAngle', 'MultiImageFilter_OnNewStatusTransformationAngle')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusTransformationAngleOriginX', 'MultiImageFilter_OnNewStatusTransformationAngleOriginX')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusTransformationAngleOriginY', 'MultiImageFilter_OnNewStatusTransformationAngleOriginY')
Script.serveEvent('CSK_MultiImageFilter.OnNewStatusRegisteredTransformationEvent', 'MultiImageFilter_OnNewStatusRegisteredTransformationEvent')

Script.serveEvent('CSK_MultiImageFilter.OnNewStatusFlowConfigPriority', 'MultiImageFilter_OnNewStatusFlowConfigPriority')
Script.serveEvent("CSK_MultiImageFilter.OnNewStatusLoadParameterOnReboot", "MultiImageFilter_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiImageFilter.OnPersistentDataModuleAvailable", "MultiImageFilter_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiImageFilter.OnNewParameterName", "MultiImageFilter_OnNewParameterName")

Script.serveEvent("CSK_MultiImageFilter.OnNewInstanceList", "MultiImageFilter_OnNewInstanceList")
Script.serveEvent("CSK_MultiImageFilter.OnNewProcessingParameter", "MultiImageFilter_OnNewProcessingParameter")
Script.serveEvent("CSK_MultiImageFilter.OnNewSelectedInstance", "MultiImageFilter_OnNewSelectedInstance")
Script.serveEvent("CSK_MultiImageFilter.OnDataLoadedOnReboot", "MultiImageFilter_OnDataLoadedOnReboot")

Script.serveEvent("CSK_MultiImageFilter.OnUserLevelOperatorActive", "MultiImageFilter_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiImageFilter.OnUserLevelMaintenanceActive", "MultiImageFilter_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiImageFilter.OnUserLevelServiceActive", "MultiImageFilter_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiImageFilter.OnUserLevelAdminActive", "MultiImageFilter_OnUserLevelAdminActive")

-- ************************ UI Events End **********************************
--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to hide UI message
local function handleOnExpired()
  Script.notifyEvent('MultiImageFilter_OnNewStatusUIMessage', 'EMPTY')
end
Timer.register(tmrUIMessage, 'OnExpired', handleOnExpired)

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("MultiImageFilter_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("MultiImageFilter_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("MultiImageFilter_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("MultiImageFilter_OnUserLevelAdminActive", status)
end
-- ***********************************************

--- Function to forward data updates from instance threads to Controller part of module
---@param eventname string Eventname to use to forward value
---@param value auto Value to forward
local function handleOnNewValueToForward(eventname, value)
  Script.notifyEvent(eventname, value)
  if eventname == "MultiImageFilter_OnNewStatusUIMessage" then
    tmrUIMessage:start()
  end
end

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
    --multiImageFilter_Instances[instance].parameters.internalObject[selectedObject][parameter] = value
end

--- Function to get access to the multiImageFilter_Model object
---@param handle handle Handle of multiImageFilter_Model object
local function setMultiImageFilter_Model_Handle(handle)
  multiImageFilter_Model = handle
  Script.releaseObject(handle)
end
funcs.setMultiImageFilter_Model_Handle = setMultiImageFilter_Model_Handle

--- Function to get access to the multiImageFilter_Instances object
---@param handle handle Handle of multiImageFilter_Instances object
local function setMultiImageFilter_Instances_Handle(handle)
  multiImageFilter_Instances = handle
  if multiImageFilter_Instances[selectedInstance].userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)

  for i = 1, #multiImageFilter_Instances do
    Script.register("CSK_MultiImageFilter.OnNewValueToForward" .. tostring(i) , handleOnNewValueToForward)
  end

  for i = 1, #multiImageFilter_Instances do
    Script.register("CSK_MultiImageFilter.OnNewValueUpdate" .. tostring(i) , handleOnNewValueUpdate)
  end

end
funcs.setMultiImageFilter_Instances_Handle = setMultiImageFilter_Instances_Handle

--- Function to update user levels
local function updateUserLevel()
  if multiImageFilter_Instances[selectedInstance].userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("MultiImageFilter_OnUserLevelAdminActive", true)
    Script.notifyEvent("MultiImageFilter_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("MultiImageFilter_OnUserLevelServiceActive", true)
    Script.notifyEvent("MultiImageFilter_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiImageFilter()

  Script.notifyEvent("MultiImageFilter_OnNewStatusModuleVersion", 'v' .. multiImageFilter_Model.version)
  Script.notifyEvent("MultiImageFilter_OnNewStatusCSKStyle", multiImageFilter_Model.styleForUI)
  Script.notifyEvent("MultiImageFilter_OnNewStatusModuleIsActive", _G.availableAPIs.default and _G.availableAPIs.specific)

  if _G.availableAPIs.default and _G.availableAPIs.specific then

    updateUserLevel()

    Script.notifyEvent('MultiImageFilter_OnNewSelectedInstance', selectedInstance)
    Script.notifyEvent("MultiImageFilter_OnNewInstanceList", helperFuncs.createStringListBySize(#multiImageFilter_Instances))

    Script.notifyEvent('MultiImageFilter_OnNewStatusUIMessage', 'EMPTY')

    Script.notifyEvent('MultiImageFilter_OnNewViewerID', 'multiImageFilterViewer' .. tostring(selectedInstance))
    Script.notifyEvent('MultiImageFilter_OnNewStatusShowImage', multiImageFilter_Instances[selectedInstance].parameters.showImage)

    Script.notifyEvent('MultiImageFilter_OnNewStatusRegisteredEvent', multiImageFilter_Instances[selectedInstance].parameters.registeredEvent)

    Script.notifyEvent('MultiImageFilter_OnNewStatusImageFilterType', multiImageFilter_Instances[selectedInstance].parameters.filterType)
    Script.notifyEvent('MultiImageFilter_OnNewStatusBlurKernelSizePix', multiImageFilter_Instances[selectedInstance].parameters.blurKernelSizePix)
    Script.notifyEvent('MultiImageFilter_OnNewStatusCannyThresholds', {multiImageFilter_Instances[selectedInstance].parameters.cannyThresholdLow, multiImageFilter_Instances[selectedInstance].parameters.cannyThresholdHigh})
    Script.notifyEvent('MultiImageFilter_OnNewStatusLabChannel', multiImageFilter_Instances[selectedInstance].parameters.labChannel)

    Script.notifyEvent('MultiImageFilter_OnNewStatusCropPositionSource', multiImageFilter_Instances[selectedInstance].parameters.cropPositionSource)
    Script.notifyEvent('MultiImageFilter_OnNewStatusCropPosX', multiImageFilter_Instances[selectedInstance].parameters.cropPosX)
    Script.notifyEvent('MultiImageFilter_OnNewStatusCropPosY', multiImageFilter_Instances[selectedInstance].parameters.cropPosY)
    Script.notifyEvent('MultiImageFilter_OnNewStatusCropWidth', multiImageFilter_Instances[selectedInstance].parameters.cropWidth)
    Script.notifyEvent('MultiImageFilter_OnNewStatusCropHeight', multiImageFilter_Instances[selectedInstance].parameters.cropHeight)
    Script.notifyEvent('MultiImageFilter_OnNewStatusRegisteredCropPositionEvent', multiImageFilter_Instances[selectedInstance].parameters.registeredCropPositionEvent)

    Script.notifyEvent('MultiImageFilter_OnNewStatusTransformationSource', multiImageFilter_Instances[selectedInstance].parameters.transformationSource)
    Script.notifyEvent('MultiImageFilter_OnNewStatusTransformationX', multiImageFilter_Instances[selectedInstance].parameters.transX)
    Script.notifyEvent('MultiImageFilter_OnNewStatusTransformationY', multiImageFilter_Instances[selectedInstance].parameters.transY)
    Script.notifyEvent('MultiImageFilter_OnNewStatusTransformationAngle', multiImageFilter_Instances[selectedInstance].parameters.transAngle)
    Script.notifyEvent('MultiImageFilter_OnNewStatusTransformationAngleOriginX', multiImageFilter_Instances[selectedInstance].parameters.transAngleOriginX)
    Script.notifyEvent('MultiImageFilter_OnNewStatusTransformationAngleOriginY', multiImageFilter_Instances[selectedInstance].parameters.transAngleOriginY)
    Script.notifyEvent('MultiImageFilter_OnNewStatusRegisteredTransformationEvent', multiImageFilter_Instances[selectedInstance].parameters.registeredTransformationEvent)

    Script.notifyEvent("MultiImageFilter_OnNewStatusFlowConfigPriority", multiImageFilter_Instances[selectedInstance].parameters.flowConfigPriority)
    Script.notifyEvent("MultiImageFilter_OnNewStatusLoadParameterOnReboot", multiImageFilter_Instances[selectedInstance].parameterLoadOnReboot)
    Script.notifyEvent("MultiImageFilter_OnPersistentDataModuleAvailable", multiImageFilter_Instances[selectedInstance].persistentModuleAvailable)
    Script.notifyEvent("MultiImageFilter_OnNewParameterName", multiImageFilter_Instances[selectedInstance].parametersName)
  end
end
Timer.register(tmrMultiImageFilter, "OnExpired", handleOnExpiredTmrMultiImageFilter)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    updateUserLevel() -- try to hide user specific content asap
  end
  tmrMultiImageFilter:start()
  return ''
end
Script.serveFunction("CSK_MultiImageFilter.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  if #multiImageFilter_Instances >= instance then
    selectedInstance = instance
    _G.logger:fine(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
    multiImageFilter_Instances[selectedInstance].activeInUI = true
    Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
    tmrMultiImageFilter:start()
  else
    _G.logger:warning(nameOfModule .. ": Selected instance does not exist.")
  end
end
Script.serveFunction("CSK_MultiImageFilter.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  if multiImageFilter_Instances then
    return #multiImageFilter_Instances
  else
    return 0
  end
end
Script.serveFunction("CSK_MultiImageFilter.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:fine(nameOfModule .. ": Add instance")
  table.insert(multiImageFilter_Instances, multiImageFilter_Model.create(#multiImageFilter_Instances+1))
  Script.deregister("CSK_MultiImageFilter.OnNewValueToForward" .. tostring(#multiImageFilter_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiImageFilter.OnNewValueToForward" .. tostring(#multiImageFilter_Instances) , handleOnNewValueToForward)
  Script.deregister("CSK_MultiImageFilter.OnNewValueUpdate" .. tostring(#multiImageFilter_Instances) , handleOnNewValueUpdate)
  Script.register("CSK_MultiImageFilter.OnNewValueUpdate" .. tostring(#multiImageFilter_Instances) , handleOnNewValueUpdate)
  handleOnExpiredTmrMultiImageFilter()
end
Script.serveFunction('CSK_MultiImageFilter.addInstance', addInstance)

local function resetInstances()
  _G.logger:info(nameOfModule .. ": Reset instances.")
  setSelectedInstance(1)
  local totalAmount = #multiImageFilter_Instances
  while totalAmount > 1 do
    Script.releaseObject(multiImageFilter_Instances[totalAmount])
    multiImageFilter_Instances[totalAmount] =  nil
    totalAmount = totalAmount - 1
  end
  handleOnExpiredTmrMultiImageFilter()
end
Script.serveFunction('CSK_MultiImageFilter.resetInstances', resetInstances)

local function setRegisterEvent(event)
  multiImageFilter_Instances[selectedInstance].parameters.registeredEvent = event
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'registeredEvent', event)
end
Script.serveFunction("CSK_MultiImageFilter.setRegisterEvent", setRegisterEvent)

local function setShowImage(status)
  _G.logger:fine(nameOfModule .. ": Set show image: " .. tostring(status))
  multiImageFilter_Instances[selectedInstance].parameters.showImage = status
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'showImage', status)
end
Script.serveFunction("CSK_MultiImageFilter.setShowImage", setShowImage)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()

  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'showImage', multiImageFilter_Instances[selectedInstance].parameters.showImage)

  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'filterType', multiImageFilter_Instances[selectedInstance].parameters.filterType)

  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'blurKernelSizePix', multiImageFilter_Instances[selectedInstance].parameters.blurKernelSizePix)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cannyThresholdLow', multiImageFilter_Instances[selectedInstance].parameters.cannyThresholdLow)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cannyThresholdHigh', multiImageFilter_Instances[selectedInstance].parameters.cannyThresholdHigh)

  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cropPositionSource', multiImageFilter_Instances[selectedInstance].parameters.cropPositionSource)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cropPosX', multiImageFilter_Instances[selectedInstance].parameters.cropPosX)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cropPosY', multiImageFilter_Instances[selectedInstance].parameters.cropPosY)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cropWidth', multiImageFilter_Instances[selectedInstance].parameters.cropWidth)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cropHeight', multiImageFilter_Instances[selectedInstance].parameters.cropHeight)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'registeredCropPositionEvent', multiImageFilter_Instances[selectedInstance].parameters.registeredCropPositionEvent)

  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transformationSource', multiImageFilter_Instances[selectedInstance].parameters.transformationSource)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transX', multiImageFilter_Instances[selectedInstance].parameters.transX)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transY', multiImageFilter_Instances[selectedInstance].parameters.transY)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transAngle', multiImageFilter_Instances[selectedInstance].parameters.transAngle)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transAngleOriginX', multiImageFilter_Instances[selectedInstance].parameters.transAngleOriginX)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transAngleOriginY', multiImageFilter_Instances[selectedInstance].parameters.transAngleOriginY)
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'registeredTransformationEvent', multiImageFilter_Instances[selectedInstance].parameters.registeredTransformationEvent)

  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'labChannel', multiImageFilter_Instances[selectedInstance].parameters.labChannel)

  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'registeredEvent', multiImageFilter_Instances[selectedInstance].parameters.registeredEvent)

end

local function setFilterType(filterType)
  multiImageFilter_Instances[selectedInstance].parameters.filterType = filterType
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'filterType', filterType)
  handleOnExpiredTmrMultiImageFilter()
end
Script.serveFunction('CSK_MultiImageFilter.setFilterType', setFilterType)

local function setLabChannel(channel)
  if channel == 'L' or channel == 'a' or channel == 'b' then
    multiImageFilter_Instances[selectedInstance].parameters.labChannel = channel
    Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'labChannel', channel)
  else
    _G.logger:warning(nameOfModule .. ": Channel " .. tostring(channel) .. " not available.")
  end
end
Script.serveFunction('CSK_MultiImageFilter.setLabChannel', setLabChannel)

local function setBlurKernelSizePix(kernelSize)
  multiImageFilter_Instances[selectedInstance].parameters.blurKernelSizePix = kernelSize
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'blurKernelSizePix', kernelSize)
end
Script.serveFunction('CSK_MultiImageFilter.setBlurKernelSizePix', setBlurKernelSizePix)

local function setCannyThreshold(range)
  multiImageFilter_Instances[selectedInstance].parameters.cannyThresholdLow = range[1]
  multiImageFilter_Instances[selectedInstance].parameters.cannyThresholdHigh = range[2]

  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cannyThresholdLow', range[1])
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cannyThresholdHigh', range[2])

end
Script.serveFunction('CSK_MultiImageFilter.setCannyThreshold', setCannyThreshold)

local function setCropPosX(posX)
  multiImageFilter_Instances[selectedInstance].parameters.cropPosX = posX
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cropPosX', posX)
end
Script.serveFunction('CSK_MultiImageFilter.setCropPosX', setCropPosX)

local function setCropPosY(posY)
  multiImageFilter_Instances[selectedInstance].parameters.cropPosY = posY
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cropPosY', posY)
end
Script.serveFunction('CSK_MultiImageFilter.setCropPosY', setCropPosY)

local function setCropWidth(width)
  multiImageFilter_Instances[selectedInstance].parameters.cropWidth = width
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cropWidth', width)
end
Script.serveFunction('CSK_MultiImageFilter.setCropWidth', setCropWidth)

local function setCropHeight(height)
  multiImageFilter_Instances[selectedInstance].parameters.cropHeight = height
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cropHeight', height)
end
Script.serveFunction('CSK_MultiImageFilter.setCropHeight', setCropHeight)

local function setCropPositionSource(source)
  multiImageFilter_Instances[selectedInstance].parameters.cropPositionSource = source
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'cropPositionSource', source)
  handleOnExpiredTmrMultiImageFilter()
end
Script.serveFunction('CSK_MultiImageFilter.setCropPositionSource', setCropPositionSource)

local function setRegisterCropPositionEvent(event)
  multiImageFilter_Instances[selectedInstance].parameters.registeredCropPositionEvent = event
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'registeredCropPositionEvent', event)
end
Script.serveFunction('CSK_MultiImageFilter.setRegisterCropPositionEvent', setRegisterCropPositionEvent)

local function setTransformationSource(source)
  multiImageFilter_Instances[selectedInstance].parameters.transformationSource = source
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transformationSource', source)
  handleOnExpiredTmrMultiImageFilter()
end
Script.serveFunction('CSK_MultiImageFilter.setTransformationSource', setTransformationSource)

local function setTransformationX(x)
  multiImageFilter_Instances[selectedInstance].parameters.transX = x
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transX', x)
end
Script.serveFunction('CSK_MultiImageFilter.setTransformationX', setTransformationX)

local function setTransformationY(y)
  multiImageFilter_Instances[selectedInstance].parameters.transY = y
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transY', y)
end
Script.serveFunction('CSK_MultiImageFilter.setTransformationY', setTransformationY)

local function setTransformationAngle(angle)
  multiImageFilter_Instances[selectedInstance].parameters.transAngle = angle
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transAngle', angle)
end
Script.serveFunction('CSK_MultiImageFilter.setTransformationAngle', setTransformationAngle)

local function setTransformationAngleOriginX(xPos)
  multiImageFilter_Instances[selectedInstance].parameters.transAngleOriginX = xPos
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transAngleOriginX', xPos)
end
Script.serveFunction('CSK_MultiImageFilter.setTransformationAngleOriginX', setTransformationAngleOriginX)

local function setTransformationAngleOriginY(yPos)
  multiImageFilter_Instances[selectedInstance].parameters.transAngleOriginY = yPos
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'transAngleOriginY', yPos)
end
Script.serveFunction('CSK_MultiImageFilter.setTransformationAngleOriginY', setTransformationAngleOriginY)

local function setRegisterTransformationEvent(event)
  multiImageFilter_Instances[selectedInstance].parameters.registeredTransformationEvent = event
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'registeredTransformationEvent', event)
end
Script.serveFunction('CSK_MultiImageFilter.setRegisterTransformationEvent', setRegisterTransformationEvent)

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_MultiImageFilter.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  for i = 1, #multiImageFilter_Instances do
    multiImageFilter_Instances[i].parameters.registeredEvent = ''
    Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', i, 'deregisterFromEvent', '')
    Script.notifyEvent('MultiImageFilter_OnNewStatusRegisteredEvent', '')
  end
end
Script.serveFunction('CSK_MultiImageFilter.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function getParameters(instanceNo)
  if instanceNo <= #multiImageFilter_Instances then
    return helperFuncs.json.encode(multiImageFilter_Instances[instanceNo].parameters)
  else
    return ''
  end
end
Script.serveFunction('CSK_MultiImageFilter.getParameters', getParameters)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiImageFilter_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiImageFilter.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if multiImageFilter_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiImageFilter_Instances[selectedInstance].parameters), multiImageFilter_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiImageFilter_Instances[selectedInstance].parametersName, multiImageFilter_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiImageFilter_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiImageFilter_Instances[selectedInstance].parametersName, multiImageFilter_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:fine(nameOfModule .. ": Send MultiImageFilter parameters with name '" .. multiImageFilter_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_MultiImageFilter.sendParameters", sendParameters)

local function loadParameters()
  if multiImageFilter_Instances[selectedInstance].persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(multiImageFilter_Instances[selectedInstance].parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters for multiImageFilterObject " .. tostring(selectedInstance) .. " from CSK_PersistentData module.")
      multiImageFilter_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()
      tmrMultiImageFilter:start()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      tmrMultiImageFilter:start()
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    tmrMultiImageFilter:start()
    return false
  end
end
Script.serveFunction("CSK_MultiImageFilter.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiImageFilter_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("MultiImageFilter_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_MultiImageFilter.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  multiImageFilter_Instances[selectedInstance].parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("MultiImageFilter_OnNewStatusFlowConfigPriority", multiImageFilter_Instances[selectedInstance].parameters.flowConfigPriority)
end
Script.serveFunction('CSK_MultiImageFilter.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

      for j = 1, #multiImageFilter_Instances do
        multiImageFilter_Instances[j].persistentModuleAvailable = false
      end
    else
      -- Check if CSK_PersistentData version is >= 3.0.0
      if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
        local parameterName, loadOnReboot, totalInstances = CSK_PersistentData.getModuleParameterName(nameOfModule, '1')
        -- Check for amount if instances to create
        if totalInstances then
          local c = 2
          while c <= totalInstances do
            addInstance()
            c = c+1
          end
        end
      end

      if not multiImageFilter_Instances then
          return
        end

      for i = 1, #multiImageFilter_Instances do
        local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule, tostring(i))

        if parameterName then
          multiImageFilter_Instances[i].parametersName = parameterName
          multiImageFilter_Instances[i].parameterLoadOnReboot = loadOnReboot
        end

        if multiImageFilter_Instances[i].parameterLoadOnReboot then
          setSelectedInstance(i)
          loadParameters()
        end
      end
      Script.notifyEvent('MultiImageFilter_OnDataLoadedOnReboot')
    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    clearFlowConfigRelevantConfiguration()
    pageCalled()
  end
end
Script.serveFunction('CSK_MultiImageFilter.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

