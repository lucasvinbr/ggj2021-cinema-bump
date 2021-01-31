-- Movement speed as world units per second
local MOVE_FORCE = 1.2
local BRAKE_FORCE = 0.2
local MOVE_ANIM_THRESHOLD = 0.45

-- control flags
CTRL_UP = 1
CTRL_DOWN = 2
CTRL_LEFT = 4
CTRL_RIGHT = 8
CTRL_ACTION = 16
CTRL_HIDE = 32

-- anim filepaths
local ANIM_MOVE = "Models/cinema_bump/character/Running.ani"
local ANIM_IDLE = "Models/cinema_bump/character/Standing Idle.ani"
local ANIM_ACTION = "Models/cinema_bump/character/Twist Dance.ani"
local ANIM_ACTION_HEAVY = "Models/cinema_bump/character/Samba Dancing.ani"
local ANIM_ACTION_EXTREME = "Models/cinema_bump/character/Dancing.ani"
local ANIM_LOSE = "Models/cinema_bump/character/Defeated.ani"


-- CinemaPlayer script object class
CinemaPlayer = ScriptObject()

function CinemaPlayer:Start()
  self.body = self.node:GetComponent("RigidBody")
  self.controls = Controls()
  self.animator = self.node:GetComponent("AnimationController")
  self.animator:Play(ANIM_IDLE, 0, true)
  -- the amount of trouble the player is making at the moment.
  -- they can only be caught if this value is above 0
  self.troubleLevel = 0.0
  -- how "hard" the player is currently troublemaking
  -- the more intense, the faster trouble is made, but it also takes more time to return to a 0 trouble level
  self.troubleIntensity = 0
  -- the score the player will receive if they successfully return to "pacific" mode
  self.accumulatedScore = 0
  self.timeSinceLastSound = 10.0
  
  local troublemeterParentNode = self.node:CreateChild("TroublemeterParent")
  troublemeterParentNode.position = Vector3(0.0, 2.0, 0.0)
  
  self.troublemeter = CreateTroublemeter(troublemeterParentNode)
  
  -- add more than one sound source to the player so that they can spam sounds
  self.soundSources = {}
  
  for i = 1, 10 do
    local source = self.node:CreateComponent("SoundSource3D")
    source.volume = 0.6
    table.insert(self.soundSources, source)
  end
  
  self.nextSoundSourceIndex = 1
end

function CinemaPlayer:GetNextSoundSource()
  
  self.nextSoundSourceIndex = self.nextSoundSourceIndex + 1
    
  if self.nextSoundSourceIndex > #self.soundSources then
    
    self.nextSoundSourceIndex = 1
    
  end
  
  return self.soundSources[self.nextSoundSourceIndex]
  
end

function CinemaPlayer:Update(timeStep)

  -- Do not move if the UI has a focused element (the console)
  if ui.focusElement ~= nil or game_over then
    return
  end

-- Clear previous controls
  self.controls:Set(CTRL_UP + CTRL_DOWN + CTRL_LEFT + CTRL_RIGHT + CTRL_ACTION, false)

  -- Read WASD keys and move the node to the corresponding direction if they are pressed
  if input:GetKeyDown(KEY_W) then self.controls:Set(CTRL_UP, true) end
  if input:GetKeyDown(KEY_S) then self.controls:Set(CTRL_DOWN, true) end
  if input:GetKeyDown(KEY_A) then self.controls:Set(CTRL_LEFT, true) end
  if input:GetKeyDown(KEY_D) then self.controls:Set(CTRL_RIGHT, true) end
  if input:GetKeyDown(KEY_SPACE) then self.controls:Set(CTRL_ACTION, true) end

  -- Toggle debug geometry with space
  if input:GetKeyPress(KEY_F3) then
    drawDebug = not drawDebug
  end

  -- save scene option for that extra debugging
  if input:GetKeyPress(KEY_F5) then
    scene_:SaveXML(fileSystem:GetProgramDir().."Data/Scenes/cinemabump.xml")
  end

  -- troublemaking!

  if self.controls:IsDown(CTRL_ACTION) then

    if self.troubleIntensity == 0 then
      self.troubleIntensity = 1 
      self.troublemeter:ToggleDisplay(true)
      self.accumulatedScore = 0
    end

    self.accumulatedScore = self.accumulatedScore + self.troubleLevel * timeStep

    if self.troubleLevel < TROUBLE_LEVEL_MAX then
      self.troubleLevel = self.troubleLevel + timeStep * self.troubleIntensity
    end

    if self.troubleLevel > self.troubleIntensity * self.troubleIntensity and self.troubleIntensity < TROUBLE_INTENSITY_MAX then
      self.troubleIntensity = self.troubleIntensity + 1
      -- when the intensity increases, the enemies may notice
      WarnEnemies(self.troubleIntensity, self.node.position)
    end

  else
    -- player's trouble level should reduce with time if they're not "active" at the moment
    if self.troubleLevel > 0.0 then
      self.troubleLevel = self.troubleLevel - (timeStep * TROUBLE_DECAY_SPEED_MULT)

      -- reduce intensity gradually too
      if self.troubleIntensity > 0 and self.troubleLevel < (self.troubleIntensity - 1) * (self.troubleIntensity - 1) then
        self.troubleIntensity = self.troubleIntensity - 1
        
        -- hide bar if intensity has just become 0
        if self.troubleIntensity == 0 then
          self.troublemeter:ToggleDisplay(false)
          
          -- add the score for this "trouble session"
          
          if score_handler:IncrementScore(RoundToInt(self.accumulatedScore)) then
            PlayScoreSound(self:GetNextSoundSource())
          end
          self.accumulatedScore = 0
        end
        
      end

    end
  end
  
  self.troublemeter:UpdateBar(self.troubleLevel, self.troubleIntensity)

  -- action animation!
  if self.troubleIntensity > 0 then
    if self.troubleIntensity < 3 then
      self.animator:PlayExclusive(ANIM_ACTION, 0, true, 0.2)
      self.animator:SetSpeed(ANIM_ACTION, self.troubleIntensity)
    elseif self.troubleIntensity < TROUBLE_INTENSITY_MAX then
      self.animator:PlayExclusive(ANIM_ACTION_HEAVY, 0, true, 0.2)
      self.animator:SetSpeed(ANIM_ACTION_HEAVY, self.troubleIntensity)
    else
      self.animator:PlayExclusive(ANIM_ACTION_EXTREME, 0, true, 0.2)
      self.animator:SetSpeed(ANIM_ACTION_EXTREME, self.troubleIntensity)
    end
  else
    self.animator:Stop(ANIM_ACTION, 0.2)
  end

  
  -- action sounds!
  self.timeSinceLastSound = self.timeSinceLastSound + timeStep
  
  if self.troubleIntensity > 0 and self.timeSinceLastSound > PLAYER_TROUBLESOUND_BASE_INTERVAL - (PLAYER_TROUBLESOUND_INTERVAL_REDUCTION_PER_INTENSITY * self.troubleIntensity) then
    PlayPlayerSound(self:GetNextSoundSource())
    self.timeSinceLastSound = 0.0
    
  end

end

function CinemaPlayer:FixedUpdate(timeStep)
  
  -- Update movement
  local moveDir = Vector3.ZERO
  local velocity = self.body.linearVelocity
  -- Velocity on the XZ plane
  local planeVelocity = Vector3(velocity.x, 0.0, velocity.z)

  -- can't move if we're hidden or acting!
  if self.troubleLevel <= 0.0 and not game_over then
    if self.controls:IsDown(CTRL_UP) then
      moveDir = moveDir + Vector3.FORWARD
    end
    if self.controls:IsDown(CTRL_DOWN) then
      moveDir = moveDir + Vector3.BACK
    end
    if self.controls:IsDown(CTRL_LEFT) then
      moveDir = moveDir + Vector3.LEFT
    end
    if self.controls:IsDown(CTRL_RIGHT) then
      moveDir = moveDir + Vector3.RIGHT
    end
  end

  -- Normalize move vector so that diagonal strafing is not faster
  if moveDir:LengthSquared() > 0.0 then
    moveDir:Normalize()
  end

  -- normally, we should consider rotation here, but not in this game's case
  self.body:ApplyImpulse(moveDir * MOVE_FORCE)

  -- apply a braking force to limit maximum ground velocity
  local brakeForce = planeVelocity * -BRAKE_FORCE
  self.body:ApplyImpulse(brakeForce)

end

function CinemaPlayer:PostUpdate(timeStep)
  -- rotate body according to which direction we're going
  local posDelta = self.body.linearVelocity
  posDelta.y = 0.0
  local velocLength = posDelta:Length()

  -- also use the move animation according to our speed
--  Log:Write(2, posDelta:ToString())
  if velocLength > MOVE_ANIM_THRESHOLD then
    self.node.rotation = self.node.rotation:Slerp(Quaternion(Vector3.FORWARD, posDelta), 10.0 * timeStep)
    self.animator:Play(ANIM_MOVE, 0, true, 0.2)
    self.animator:SetSpeed(ANIM_MOVE, velocLength / 3)
  else
    self.animator:Stop(ANIM_MOVE, 0.2)
    self.animator:Play(ANIM_IDLE, 0, true, 0.2)
  end


end

function CinemaPlayer:FoundByEnemy(finder)
  
  -- an enemy has found us!
  -- are we currently "suspicious"? If we are, we lose
  if self.troubleLevel > 0 and not game_over then
    game_over = true
    finder:CheerCaughtPlayer()
    
    self.troublemeter:ToggleDisplay(false)
    
    score_handler:SaveScores()
    
    self.animator:PlayExclusive(ANIM_LOSE, 0, false, 0.1)
    PlayYouLoseSound(self:GetNextSoundSource())
    
    ToggleMainMenu(true)
  end
  
  
end
