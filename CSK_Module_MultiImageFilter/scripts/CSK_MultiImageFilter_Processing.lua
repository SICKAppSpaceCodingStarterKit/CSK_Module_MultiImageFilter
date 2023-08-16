---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('ImageProcessing/MultiImageFilter/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiImageFilter'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiImageFilterInstanceNumber = scriptParams:get('multiImageFilterInstanceNumber') -- number of this instance
local multiImageFilterInstanceNumberString = tostring(multiImageFilterInstanceNumber) -- number of this instance as string
local viewerId = scriptParams:get('viewerId')
local viewer = View.create(viewerId)

-- Event to notify result of processing
Script.serveEvent("CSK_MultiImageFilter.OnNewImage" .. multiImageFilterInstanceNumberString, "MultiImageFilter_OnNewImage" .. multiImageFilterInstanceNumberString, 'object:?:Image') -- Edit this accordingly
-- Event to forward content from this thread to Controller to show e.g. on UI
Script.serveEvent("CSK_MultiImageFilter.OnNewValueToForward".. multiImageFilterInstanceNumberString, "MultiImageFilter_OnNewValueToForward" .. multiImageFilterInstanceNumberString, 'string, auto')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiImageFilter.OnNewValueUpdate" .. multiImageFilterInstanceNumberString, "MultiImageFilter_OnNewValueUpdate" .. multiImageFilterInstanceNumberString, 'int, string, auto, int:?')

local processingParams = {}
processingParams.registeredEvent = scriptParams:get('registeredEvent')
processingParams.activeInUI = false
processingParams.showImage = scriptParams:get('showImage')

processingParams.filterType = scriptParams:get('filterType')

processingParams.blurKernelSizePix = scriptParams:get('blurKernelSizePix')

processingParams.cannyThresholdLow = scriptParams:get('cannyThresholdLow')
processingParams.cannyThresholdHigh = scriptParams:get('cannyThresholdHigh')

processingParams.cropPosX = scriptParams:get('cropPosX')
processingParams.cropPosY = scriptParams:get('cropPosY')
processingParams.cropWidth = scriptParams:get('cropWidth')
processingParams.cropHeight = scriptParams:get('cropHeight')

local function handleOnNewProcessing(img)

  _G.logger:info(nameOfModule .. ": Check object on instance No." .. multiImageFilterInstanceNumberString)

  local resultImage

  if processingParams.filterType == 'Gray' then
    resultImage = Image.toGray(img)
  elseif processingParams.filterType == 'Canny' then
    resultImage = Image.canny(img, processingParams.cannyThresholdHigh, processingParams.cannyThresholdLow)
  elseif processingParams.filterType == 'Blur' then
    resultImage = Image.blur(img, processingParams.blurKernelSizePix)
  elseif processingParams.filterType == 'Crop' then
    resultImage = Image.crop(img, processingParams.cropPosX, processingParams.cropPosY, processingParams.cropWidth, processingParams.cropHeight)
  end

  if processingParams.showImage and processingParams.activeInUI then
    viewer:addImage(resultImage)
    viewer:present("LIVE")
  end

  if resultImage then
    Script.notifyEvent('MultiImageFilter_OnNewImage'.. multiImageFilterInstanceNumberString, resultImage)
  end

end
Script.serveFunction("CSK_MultiImageFilter.processInstance"..multiImageFilterInstanceNumberString, handleOnNewProcessing, 'object:?:Alias', 'bool:?') -- Edit this according to this function

--- Function to handle updates of processing parameters from Controller
---@param multiImageFilterNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
---@param internalObjectNo int? Number of object
local function handleOnNewProcessingParameter(multiImageFilterNo, parameter, value, internalObjectNo)

  if multiImageFilterNo == multiImageFilterInstanceNumber then -- set parameter only in selected script
    _G.logger:info(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiImageFilterInstanceNo." .. tostring(multiImageFilterNo) .. " to value = " .. tostring(value))

    --[[
    if internalObjectNo then
      _G.logger:info(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiImageFilterInstanceNo." .. tostring(multiImageFilterNo) .. " of internalObject No." .. tostring(internalObjectNo) .. " to value = " .. tostring(value))
      processingParams.internalObjects[internalObjectNo][parameter] = value

    elseif parameter == 'FullSetup' then
      if type(value) == 'userdata' then
        if Object.getType(value) == 'Container' then
            setAllProcessingParameters(value)
        end
      end

    -- further checks
    --elseif parameter == 'chancelEditors' then
    end

    else
    ]]

    if parameter == 'registeredEvent' then
      _G.logger:info(nameOfModule .. ": Register instance " .. multiImageFilterInstanceNumberString .. " on event " .. value)
      if processingParams.registeredEvent ~= '' then
        Script.deregister(processingParams.registeredEvent, handleOnNewProcessing)
      end
      processingParams.registeredEvent = value
      Script.register(value, handleOnNewProcessing)

    -- elseif parameter == 'someSpecificParameter' then
    --   --Setting something special...
    --   processingParams.specificVariable = value
    --   --Do some more specific...

    else
      processingParams[parameter] = value
      --if  parameter == 'showImage' and value == false then
      --  viewer:clear()
      --  viewer:present()
      --end
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiImageFilter.OnNewProcessingParameter", handleOnNewProcessingParameter)
