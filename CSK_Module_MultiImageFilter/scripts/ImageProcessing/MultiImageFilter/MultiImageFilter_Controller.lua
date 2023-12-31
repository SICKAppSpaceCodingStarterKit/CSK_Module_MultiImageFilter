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

Script.serveEvent("CSK_MultiImageFilter.OnNewResultNUM", "MultiImageFilter_OnNewResultNUM")
Script.serveEvent("CSK_MultiImageFilter.OnNewValueToForwardNUM", "MultiImageFilter_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiImageFilter.OnNewValueUpdateNUM", "MultiImageFilter_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------
-- Script.serveEvent("CSK_MultiImageFilter.OnNewEvent", "MultiImageFilter_OnNewEvent")
Script.serveEvent('CSK_MultiImageFilter.OnNewResult', 'MultiImageFilter_OnNewResult')

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

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

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
end

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
    multiImageFilter_Instances[instance].parameters.internalObject[selectedObject][parameter] = value
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
  -- Script.notifyEvent("MultiImageFilter_OnNewEvent", false)

  updateUserLevel()

  Script.notifyEvent('MultiImageFilter_OnNewSelectedInstance', selectedInstance)
  Script.notifyEvent("MultiImageFilter_OnNewInstanceList", helperFuncs.createStringListBySize(#multiImageFilter_Instances))

  Script.notifyEvent("MultiImageFilter_OnNewStatusLoadParameterOnReboot", multiImageFilter_Instances[selectedInstance].parameterLoadOnReboot)
  Script.notifyEvent("MultiImageFilter_OnPersistentDataModuleAvailable", multiImageFilter_Instances[selectedInstance].persistentModuleAvailable)
  Script.notifyEvent("MultiImageFilter_OnNewParameterName", multiImageFilter_Instances[selectedInstance].parametersName)

  -- ...
end
Timer.register(tmrMultiImageFilter, "OnExpired", handleOnExpiredTmrMultiImageFilter)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrMultiImageFilter:start()
  return ''
end
Script.serveFunction("CSK_MultiImageFilter.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  selectedInstance = instance
  _G.logger:info(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
  multiImageFilter_Instances[selectedInstance].activeInUI = true
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  tmrMultiImageFilter:start()
end
Script.serveFunction("CSK_MultiImageFilter.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  return #multiImageFilter_Instances
end
Script.serveFunction("CSK_MultiImageFilter.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:info(nameOfModule .. ": Add instance")
  table.insert(multiImageFilter_Instances, multiImageFilter_Model.create(#multiImageFilter_Instances+1))
  Script.deregister("CSK_MultiImageFilter.OnNewValueToForward" .. tostring(#multiImageFilter_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiImageFilter.OnNewValueToForward" .. tostring(#multiImageFilter_Instances) , handleOnNewValueToForward)
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

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'value', multiImageFilter_Instances[selectedInstance].parameters.value)

  -- optionally for internal objects...
  --[[
  -- Send config to instances
  local params = helperFuncs.convertTable2Container(multiImageFilter_Instances[selectedInstance].parameters.internalObject)
  Container.add(data, 'internalObject', params, 'OBJECT')
  Script.notifyEvent('MultiImageFilter_OnNewProcessingParameter', selectedInstance, 'FullSetup', data)
  ]]

end

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiImageFilter_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiImageFilter.setParameterName", setParameterName)

local function sendParameters()
  if multiImageFilter_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiImageFilter_Instances[selectedInstance].parameters), multiImageFilter_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiImageFilter_Instances[selectedInstance].parametersName, multiImageFilter_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiImageFilter_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiImageFilter_Instances[selectedInstance].parametersName, multiImageFilter_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:info(nameOfModule .. ": Send MultiImageFilter parameters with name '" .. multiImageFilter_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
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
      CSK_MultiImageFilter.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
  tmrMultiImageFilter:start()
end
Script.serveFunction("CSK_MultiImageFilter.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiImageFilter_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_MultiImageFilter.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
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
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

