local MIN_TIME_LIGHT_CHANGE = 0.15
local MAX_TIME_LIGHT_CHANGE = 7.5

local MIN_LIGHT_INTENSITY = 0.45
local MAX_LIGHT_INTENSITY = 1.0


function CreateCinemaLight()

  local lightNode = scene_:CreateChild("CinemaLight")
  
  -- since our POV is from the cinema screen, use the camera's angle as the main light's angle too
  lightNode.position = cameraNode.position
  lightNode.rotation = Quaternion(25.0, 0.0, 0.0)
  local light = lightNode:CreateComponent("Light")
  light.lightType = LIGHT_POINT
  light.castShadows = true
  light.shadowBias = BiasParameters(0.00025, 0.5)
  light:SetBrightness(1.45)
  light.range = GAME_BOUNDS_Z + 8.0
  -- Set cascade splits at 10, 50 and 200 world units, fade shadows out at 80% of maximum shadow distance
  light.shadowCascade = CascadeParameters(10.0, 50.0, 200.0, 0.0, 0.8)
  
  lightNode:CreateScriptObject("CinemaLight")

end

-- CinemaLight script object class
CinemaLight = ScriptObject()

function CinemaLight:Start()
  
  self.light = self.node:GetComponent("Light")
--  self.lightAnim = nil
  self:ChangeLight()
  
end

function CinemaLight:Update(timeStep)
  
  self.timeSinceLightChange = self.timeSinceLightChange + timeStep
  
  if self.timeSinceLightChange > self.nextLightChangeTime then
    
    self:ChangeLight()
    
  end
  
  local lightChangeProgress = self.timeSinceLightChange / self.nextLightChangeTime
  
  self.light.color = self.curLightColor:Lerp(self.nextLightColor, lightChangeProgress)

end

function CinemaLight:ChangeLight()
  
  self.timeSinceLightChange = 0.0
  self:SetNextLightChangeTime()
  
  self.curLightColor = self.light.color
  self.nextLightColor = Color(Random(0.4, 1.0), Random(0.6, 1.0), Random(0.6, 1.0))
  
--  if self.lightAnim ~= nil then
--    self.lightAnim:delete()
--  end
  
  -- Create light color animation
--  self.lightAnim = ValueAnimation:new()
--  self.lightAnim:SetKeyFrame(0.0, Variant(self.light.color))
--  self.lightAnim:SetKeyFrame(self.nextLightChangeTime, Variant(Color(1,0,0)))
--  self.light:SetAttributeAnimation("Color", self.lightAnim)
  
end

function CinemaLight:SetNextLightChangeTime()
  self.nextLightChangeTime = Random(MIN_TIME_LIGHT_CHANGE, MAX_TIME_LIGHT_CHANGE)
end
