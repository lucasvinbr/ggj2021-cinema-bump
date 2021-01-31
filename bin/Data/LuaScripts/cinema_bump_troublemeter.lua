-- it's the component showing how much trouble the player is making at the moment

local centerPivot = Vector2(0.5,0.5)

local meter_frame_texture = "Urho2D/cinema_bump/06-bar-frame.png"
local meter_fill_texture = "Urho2D/cinema_bump/07-bar-fill-main.png"
local star_filled_texture = "Urho2D/cinema_bump/01-star-filled.png"
local star_empty_texture = "Urho2D/cinema_bump/02-star-empty.png"

local troublemeter_scale = 0.35
local troublemeter_scaleAnim_time = 0.35

local troublemeter = nil
local troublemeterFill = nil

function CreateTroublemeter(troublemeterParent)

  if troublemeter == nil then
    local troublemeterNode = scene_:CreateChild("Troublemeter")
    troublemeterNode:LookAt(cameraNode.position)

    troublemeterNode.position = troublemeterParent.position
    troublemeterNode.scale = Vector3.ONE * troublemeter_scale

    local troublemeterFrameNode = troublemeterNode:CreateChild("Troublemeter_Frame")

    local troublemeterFrameSprite = troublemeterFrameNode:CreateComponent("StaticSprite2D")
    troublemeterFrameSprite.sprite = cache:GetResource("Sprite2D", meter_frame_texture)
--    troublemeterFrameSprite.border = IntRect(45, 45, 45, 45)

    troublemeterFill = troublemeterFrameNode:CreateChild("Troublemeter_Fill")
    local troublemeterFillSprite = troublemeterFill:CreateComponent("StaticSprite2D")
    troublemeterFillSprite.sprite = cache:GetResource("Sprite2D", meter_fill_texture)
    troublemeterFillSprite.orderInLayer = 1
    troublemeterFillSprite:SetUseHotSpot(true)
    troublemeterFillSprite:SetHotSpot(Vector2(0.96, 0.5))

    troublemeterFill.position = Vector3(3.90885, 0, 0)

    troublemeterNode:LookAt(cameraNode.position)

    troublemeter = troublemeterNode:CreateScriptObject("CinemaTroublemeter")
    troublemeter.meterFill = troublemeterFill

    troublemeter.basePos = troublemeterNode.position
    
    troublemeter.troubleStars = {}
    -- create intensity level marker stars
    for i = 1, TROUBLE_INTENSITY_MAX - 1 do
      local troublemeterStar = troublemeterNode:CreateChild("Troublemeter_Star")
      troublemeterStar.position = Vector3(3.3 + (-2.25 * (i - 1)), 1.25, 0)
      
      local troublemeterStarSprite = troublemeterStar:CreateComponent("StaticSprite2D")
      troublemeterStarSprite.sprite = cache:GetResource("Sprite2D", star_filled_texture)
      
      troublemeterStar.scale = Vector3.ONE * 0.25
      
      table.insert(troublemeter.troubleStars, troublemeterStarSprite)
    end

  end

  troublemeter.followParent = troublemeterParent
  troublemeter.node.scale = Vector3.ZERO

  return troublemeter
end



CinemaTroublemeter = ScriptObject()


function CinemaTroublemeter:Start()
  
  self.animTime = 0.0
  self.targetScale = Vector3.ZERO
  
end

function CinemaTroublemeter:Update(timeStep)

  if self.followParent == nil then return end

  self.node.position = self.followParent.worldPosition
  
  if self.animTime < troublemeter_scaleAnim_time then
    self.animTime = self.animTime + timeStep
    
    self.node.scale = self.node.scale:Lerp(self.targetScale, self.animTime / troublemeter_scaleAnim_time)
  end

end

function CinemaTroublemeter:ToggleDisplay(display)
  
  if display then
    
    self.targetScale = Vector3.ONE * troublemeter_scale
    
  else
    
    self.targetScale = Vector3.ZERO
    
  end
  
  self.animTime = 0.0
  
end

function CinemaTroublemeter:UpdateBar(troubleLevel, troubleIntensity)


  if troubleLevel <= 0.0 then
    return
  end


  if troubleLevel >= TROUBLE_LEVEL_MAX then
    self.meterFill.scale = Vector3.ONE
  else

    local troubleToNextLevel = troubleIntensity * troubleIntensity
    local troubleLimitFromPreviousLevel = (troubleIntensity - 1) * (troubleIntensity - 1)
    
    if troubleIntensity == TROUBLE_INTENSITY_MAX then troubleToNextLevel = TROUBLE_LEVEL_MAX end

    self.meterFill.scale = Vector3((troubleLevel - troubleLimitFromPreviousLevel) / (troubleToNextLevel - troubleLimitFromPreviousLevel), 1.0, 1.0)

  end

  for i = 1, #self.troubleStars do
    if troubleIntensity > i then
      self.troubleStars[i].sprite = cache:GetResource("Sprite2D", star_filled_texture)
    else
      self.troubleStars[i].sprite = cache:GetResource("Sprite2D", star_empty_texture)
    end
  end

  -- the bar shakes with troublesome power!!!
  self.node.position = self.basePos + (Vector3(Random(-1.0, 1.0), Random(-1.0, 1.0), 0.0) * ((troubleIntensity * troubleIntensity) / 1000))

end

