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
local tempImage = nil

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

processingParams.labChannel = scriptParams:get('labChannel')

processingParams.cannyThresholdLow = scriptParams:get('cannyThresholdLow')
processingParams.cannyThresholdHigh = scriptParams:get('cannyThresholdHigh')

processingParams.cropPositionSource = scriptParams:get('cropPositionSource')
processingParams.cropPosX = scriptParams:get('cropPosX')
processingParams.cropPosY = scriptParams:get('cropPosY')
processingParams.cropWidth = scriptParams:get('cropWidth')
processingParams.cropHeight = scriptParams:get('cropHeight')
processingParams.registeredCropPositionEvent = scriptParams:get('registeredCropPositionEvent')

processingParams.transformationSource = scriptParams:get('transformationSource')
processingParams.transX = scriptParams:get('transX')
processingParams.transY = scriptParams:get('transY')
processingParams.transAngle = scriptParams:get('transAngle')
processingParams.transAngleOriginX = scriptParams:get('transAngleOriginX')
processingParams.transAngleOriginY = scriptParams:get('transAngleOriginY')
processingParams.transAngleOrigin = Point.create(processingParams.transAngleOriginX, processingParams.transAngleOriginY)
processingParams.registeredTransformationEvent = scriptParams:get('registeredTransformationEvent')
processingParams.transform = Transform.createRigid2D(math.rad(processingParams.transAngle), processingParams.transX, processingParams.transY, processingParams.transAngleOrigin)

local function handleOnNewProcessing(img, translation)

  _G.logger:fine(nameOfModule .. ": Check object on instance No." .. multiImageFilterInstanceNumberString)

  local resultImage

  if processingParams.filterType == 'Gray' then
    resultImage = Image.toGray(img)
  elseif processingParams.filterType == 'Lab' then
    local imgType = Image.getType(img)
    if imgType == 'RGB24' then
      if processingParams.labChannel == 'L' then
        resultImage = Image.toLab(img)
      elseif processingParams.labChannel == 'a' then
        _, resultImage = Image.toLab(img)
      elseif processingParams.labChannel == 'b' then
        _, __, resultImage = Image.toLab(img)
      end
    else
      _G.logger:warning(nameOfModule .. ": Lab conversion on instance No." .. multiImageFilterInstanceNumberString .. " not possible. No RGB image.")
      if processingParams.activeInUI then
        Script.notifyEvent("MultiImageFilter_OnNewValueToForward" .. multiImageFilterInstanceNumberString, "MultiImageFilter_OnNewStatusUIMessage", 'LOG')
      end
    end
  elseif processingParams.filterType == 'Canny' then
    local imgType = Image.getType(img)
    if imgType == 'UINT8' then
      resultImage = Image.canny(img, processingParams.cannyThresholdHigh, processingParams.cannyThresholdLow)
    else
      _G.logger:warning(nameOfModule .. ": Canny filter on instance No." .. multiImageFilterInstanceNumberString .. " only supports UINT8 images.")
      if processingParams.activeInUI then
        Script.notifyEvent("MultiImageFilter_OnNewValueToForward" .. multiImageFilterInstanceNumberString, "MultiImageFilter_OnNewStatusUIMessage", 'LOG')
      end
    end
  elseif processingParams.filterType == 'Blur' then
    local imgType = Image.getType(img)
    if imgType ~= 'RGB24' then
      resultImage = Image.blur(img, processingParams.blurKernelSizePix)
    else
      _G.logger:warning(nameOfModule .. ": Blur filter on instance No." .. multiImageFilterInstanceNumberString .. " does not supports RGB images.")
      if processingParams.activeInUI then
        Script.notifyEvent("MultiImageFilter_OnNewValueToForward" .. multiImageFilterInstanceNumberString, "MultiImageFilter_OnNewStatusUIMessage", 'LOG')
      end
    end
  elseif processingParams.filterType == 'Crop' then
    if processingParams.cropPositionSource == 'MANUAL' then
      resultImage = Image.crop(img, processingParams.cropPosX, processingParams.cropPosY, processingParams.cropWidth, processingParams.cropHeight)
    elseif processingParams.cropPositionSource == 'EXTERNAL' then
      if img then
        tempImage = img
        return
      elseif translation and tempImage then
        local singlePose
        if type(translation) == 'table' then
          singlePose = translation[1]
        else
          singlePose = translation
        end

        if type(singlePose) == 'userdata' then
          local _, posX, posY = Transform.decomposeRigid2D(singlePose)
          resultImage = Image.crop(tempImage, posX + processingParams.cropPosX, posY+processingParams.cropPosY, processingParams.cropWidth, processingParams.cropHeight)
        end
        Script.releaseObject(tempImage)
        tempImage = nil
      end
    end

  elseif processingParams.filterType == 'Transform' then
    if processingParams.transformationSource == 'MANUAL' then
      resultImage = Image.transform(img, processingParams.transform)
    elseif processingParams.transformationSource == 'EXTERNAL' then
      if img then
        tempImage = img
        return
      elseif translation and tempImage then

        local singlePose
        if type(translation) == 'table' then
          singlePose = translation[1]
        else
          singlePose = translation
        end

        if type(singlePose) == 'userdata' then
          local transPose = singlePose:invert()
          local movedPose = Transform.translate2D(transPose, 0,0)
          local fullTrans = Transform.compose(movedPose, processingParams.transform)
          resultImage = Image.transform(tempImage, fullTrans)
        end

        Script.releaseObject(tempImage)
        tempImage = nil
      end
    end
  end

  if resultImage then
    if processingParams.showImage and processingParams.activeInUI then
      viewer:addImage(resultImage)
      viewer:present("LIVE")
    end
    Script.notifyEvent('MultiImageFilter_OnNewImage'.. multiImageFilterInstanceNumberString, resultImage)
  end

end
Script.serveFunction("CSK_MultiImageFilter.processInstance"..multiImageFilterInstanceNumberString, handleOnNewProcessing, 'object:?:Image,object:?*:Transform', 'bool:?') -- Edit this according to this function

-- Function to use transformation data on presaved image
---@param trans Transform Transformation to transform image
local function handleOnNewTransformationProcessing(trans)
  handleOnNewProcessing(nil, trans)
end

-- Function to use transformation data on presaved image to crop image
---@param trans Transform Transformation to use for cropping image
local function handleOnNewCropProcessing(trans)
  handleOnNewProcessing(nil, trans)
end

--- Function only used to forward the content from events to the served function.
--- This is only needed, as deregistering from the event would internally release the served function and would make it uncallable from external.
---@param image Image Image to process
local function tempHandleOnNewProcessing(image)
  handleOnNewProcessing(image)
end

--- Function to handle updates of processing parameters from Controller
---@param multiImageFilterNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
---@param internalObjectNo int? Number of object
local function handleOnNewProcessingParameter(multiImageFilterNo, parameter, value, internalObjectNo)

  if multiImageFilterNo == multiImageFilterInstanceNumber then -- set parameter only in selected script
    _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiImageFilterInstanceNo." .. tostring(multiImageFilterNo) .. " to value = " .. tostring(value))

    if parameter == 'registeredEvent' then
      _G.logger:fine(nameOfModule .. ": Register instance " .. multiImageFilterInstanceNumberString .. " on event " .. value)
      if processingParams.registeredEvent ~= '' then
        Script.deregister(processingParams.registeredEvent, tempHandleOnNewProcessing)
      end
      processingParams.registeredEvent = value
      Script.register(value, tempHandleOnNewProcessing)

    elseif parameter == 'deregisterFromEvent' then
      _G.logger:fine(nameOfModule .. ": Deregister instance " .. multiImageFilterInstanceNumberString .. " from event")
      Script.deregister(processingParams.registeredEvent, tempHandleOnNewProcessing)
      processingParams.registeredEvent = ''

    elseif parameter == 'registeredTransformationEvent' then
      if processingParams.registeredTransformationEvent ~= '' then
        Script.deregister(processingParams.registeredTransformationEvent, handleOnNewTransformationProcessing)
      end
      processingParams.registeredTransformationEvent = value
      if processingParams.transformationSource == 'EXTERNAL' then
        _G.logger:fine(nameOfModule .. ": Register instance " .. multiImageFilterInstanceNumberString .. " on transformation event " .. value)
        Script.register(value, handleOnNewTransformationProcessing)
      else
        _G.logger:info(nameOfModule .. ": First set transformation source to 'EXTERNAL'.")
      end

    elseif parameter == 'transformationSource' then
      processingParams[parameter] = value
      if value == 'EXTERNAL' then
        if processingParams.registeredTransformationEvent ~= '' then
          Script.deregister(processingParams.registeredTransformationEvent, handleOnNewTransformationProcessing)
          _G.logger:fine(nameOfModule .. ": Register instance " .. multiImageFilterInstanceNumberString .. " on transformation event " .. tostring(processingParams.registeredTransformationEvent))
          Script.register(processingParams.registeredTransformationEvent, handleOnNewTransformationProcessing)
        end
      elseif value == 'MANUAL' then
        Script.deregister(processingParams.registeredTransformationEvent, handleOnNewTransformationProcessing)
      end

      elseif parameter == 'registeredCropPositionEvent' then
        if processingParams.cropPositionSource == 'EXTERNAL' then
          _G.logger:fine(nameOfModule .. ": Register instance " .. multiImageFilterInstanceNumberString .. " on crop event " .. value)
          if processingParams.registeredCropPositionEvent ~= '' then
            Script.deregister(processingParams.registeredCropPositionEvent, handleOnNewCropProcessing)
          end
          processingParams.registeredCropPositionEvent = value
          Script.register(value, handleOnNewCropProcessing)
        else
          _G.logger:fine(nameOfModule .. ": First set crop source to 'EXTERNAL'.")
        end

      elseif parameter == 'cropPositionSource' then
        processingParams[parameter] = value
        if value == 'EXTERNAL' then
          if processingParams.registeredCropPositionEvent ~= '' then
            Script.deregister(processingParams.registeredCropPositionEvent, handleOnNewCropProcessing)
            _G.logger:fine(nameOfModule .. ": Register instance " .. multiImageFilterInstanceNumberString .. " on crop event " .. tostring(processingParams.registeredCropPositionEvent))
            Script.register(processingParams.registeredCropPositionEvent, handleOnNewCropProcessing)
          end
        elseif value == 'MANUAL' then
          Script.deregister(processingParams.registeredCropPositionEvent, handleOnNewCropProcessing)
        end

    elseif parameter == 'transX' or parameter == 'transY' or parameter == 'transAngle' or parameter =='transAngleOriginX' or parameter == 'transAngleOriginY' then
      processingParams[parameter] = value
      processingParams.transAngleOrigin = Point.create(processingParams.transAngleOriginX, processingParams.transAngleOriginY)
      processingParams.transform = Transform.createRigid2D(math.rad(processingParams.transAngle), processingParams.transX, processingParams.transY, processingParams.transAngleOrigin)
    else
      processingParams[parameter] = value
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiImageFilter.OnNewProcessingParameter", handleOnNewProcessingParameter)
