local DECISION_INTERVAL = 5.0

-- CinemaEnemy script object class
CinemaEnemy = ScriptObject()

function CinemaEnemy:Start()
  
  self.navigation = self.node:GetComponent("CrowdAgent")
  self.animator = self.node:GetComponent("AnimationController")
  self.timeSinceLastDecision = 0.0
  self:SubscribeToEvent(self.node:GetChild("EnemyLightCone", true), "NodeCollision", "CinemaEnemy:HandleLightConeCollision")
end

function CinemaEnemy:Update(timeStep)
  
  if game_over then return end
  
  self.timeSinceLastDecision = self.timeSinceLastDecision + timeStep
  
  if self.timeSinceLastDecision > DECISION_INTERVAL then
    
    self:DecideMoveTo(GetRandomDestination())
    
  end

end

function CinemaEnemy:DecideMoveTo(targetPos)
  
  self.timeSinceLastDecision = 0.0
  self.navigation:SetTargetPosition(targetPos)
  
end

function CinemaEnemy:HandleLightConeCollision(eventType, eventData)
    -- Get the other colliding body, make sure it is moving (has nonzero mass)
    local otherNode = eventData["OtherNode"]:GetPtr("Node")

    otherNode:GetScriptObject("CinemaPlayer"):FoundByEnemy(self)
end

function CinemaEnemy:CheerCaughtPlayer()
  self.navigation.enabled = false
  self.animator:PlayExclusive("Models/cinema_bump/character/Twist Dance.ani", 0, true, 0.2)
end