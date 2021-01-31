-- CinemaPlayer script object class
CinemaPlayer = ScriptObject()

function CinemaPlayer:Start()
  self.body = self.node:GetComponent("RigidBody")
  self.controls = Controls()
  self.animator = self.node:GetComponent("AnimationController")
  self.animator:Play("Models/Genericus/test_stand_idle.ani", 0, true)
end

function CinemaPlayer:Update(timeStep)

  -- Do not move if the UI has a focused element (the console)
  if ui.focusElement ~= nil then
    return
  end

-- Clear previous controls
  self.controls:Set(CTRL_UP + CTRL_DOWN + CTRL_LEFT + CTRL_RIGHT +, false)

  -- Read WASD keys and move the node to the corresponding direction if they are pressed
  if input:GetKeyDown(KEY_W) then self.controls:Set(CTRL_UP, true) end
  if input:GetKeyDown(KEY_S) then self.controls:Set(CTRL_DOWN, true) end
  if input:GetKeyDown(KEY_A) then self.controls:Set(CTRL_LEFT, true) end
  if input:GetKeyDown(KEY_D) then self.controls:Set(CTRL_RIGHT, true) end

  -- Toggle debug geometry with space
  if input:GetKeyPress(KEY_SPACE) then
    drawDebug = not drawDebug
  end
  
  -- save scene option for that extra debugging
  if input:GetKeyPress(KEY_F5) then
    scene_:SaveXML(fileSystem:GetProgramDir().."Data/Scenes/cinemabump.xml")
  end
end

function CinemaPlayer:FixedUpdate(timeStep)

  -- Update movement
  local moveDir = Vector3.ZERO
  local velocity = self.body.linearVelocity
  -- Velocity on the XZ plane
  local planeVelocity = Vector3(velocity.x, 0.0, velocity.z)

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