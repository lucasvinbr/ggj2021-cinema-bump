gameDynamicElementsParent = nil

local enemySpawnPosition = Vector3(4.4, 0.0, 6.6)
local playerSpawnPosition = Vector3(0.0, 0.5, -2.0)

local enemiesList = {}

function StartGame()
  
  CleanupGame()
  
  game_over = false
  
  gameDynamicElementsParent = scene_:CreateChild("DynamicElements")
  
  gameDynamicElementsParent:CreateScriptObject("CinemaSpawner")
  
  CreatePlayer()
  
  CreateEnemy()
  
end

function WarnEnemies(troubleIntensity, troublemakerPosition)
  
  for i = 1, #enemiesList do
    if Random(1, TROUBLE_INTENSITY_MAX * 1.5) <= troubleIntensity then
      enemiesList[i]:DecideMoveTo(troublemakerPosition)
      break
    end
  end
  
end

function CleanupGame()
  
  enemiesList = {}
  
  if gameDynamicElementsParent ~= nil then
    gameDynamicElementsParent:Remove()
  end
  
  score_handler:ResetScore()
  
end

function CreateChair(position)
  local chairNode = scene_:CreateChild("Chair")
  chairNode.position = position

  -- Make the chair physical by adding RigidBody and CollisionShape components
  local body = chairNode:CreateComponent("RigidBody")
  body.collisionLayer = COLLAYER_SCENARIO
  local shape = chairNode:CreateComponent("CollisionShape")

  -- Set a box shape of size 1 x 1 x 1 for collision. The shape will be scaled with the scene node scale
  shape:SetBox(Vector3(1.0, 1.0, 1.0))

  -- add a model to the visible walls
  local chairModel = chairNode:CreateComponent("StaticModel")
  chairModel.model = cache:GetResource("Model", "Models/cinema_bump/chair.mdl")
  chairModel.material = cache:GetResource("Material", "Materials/cinema_bump/chair_material.xml")
  local obstacle = chairNode:CreateComponent("Obstacle")
  obstacle.radius = chairNode.scale.x * 0.75
  obstacle.height = chairNode.scale.y
  
  return chairNode
end

function CreatePlayer()

  local playerNode = gameDynamicElementsParent:CreateChild("Player")
  playerNode.position = playerSpawnPosition

  local modelObject = playerNode:CreateComponent("AnimatedModel")
  modelObject.model = cache:GetResource("Model", "Models/cinema_bump/character/player.mdl")
  modelObject.material = cache:GetResource("Material", "Materials/cinema_bump/player_mat.xml")
  modelObject.castShadows = true

  playerNode:CreateComponent("AnimationController")
  -- Set the model to also update when invisible to avoid staying invisible when the model should come into
  -- view, but does not as the bounding box is not updated
  modelObject.updateInvisible = true

  -- Create a rigid body and a collision shape
  local body = playerNode:CreateComponent("RigidBody")

  -- body should move freely in X and Z axis, but not Y, and shouldn't rotate due to physics
  body:SetMass(1.0)
  body:SetUseGravity(true)
  body:SetAngularFactor(Vector3.ZERO)
--  body:SetLinearFactor(Vector3(1.0, 0.0, 1.0))
  body:SetCollisionLayer(COLLAYER_PLAYER)
  -- player collides with everything: balls, scenario and other players


  local shape = playerNode:CreateComponent("CollisionShape")
  -- Create the capsule shape with an offset so that it is correctly aligned with the model, which
  -- has its origin at the feet
  shape:SetCapsule(0.7, 2.0, Vector3(0.0, 1.0, 0.0))

  

  -- Create a custom script object that reacts to collisions and creates the ragdoll
  local playerScript = playerNode:CreateScriptObject("CinemaPlayer")
  
end


function CreateEnemy()
  local enemyNode = gameDynamicElementsParent:CreateChild("Enemy")
  enemyNode.position = enemySpawnPosition

  local modelObject = enemyNode:CreateComponent("AnimatedModel")
  modelObject.model = cache:GetResource("Model", "Models/cinema_bump/character/Lanterninha.mdl")
  modelObject.material = cache:GetResource("Material", "Materials/cinema_bump/Lanterninha_mat.xml")
  modelObject.castShadows = true

  local animCtrl = enemyNode:CreateComponent("AnimationController")
  animCtrl:Play("Models/cinema_bump/character/Lantertinha Idle.ani", 0, true, 0.0)
  -- Set the model to also update when invisible to avoid staying invisible when the model should come into
  -- view, but does not as the bounding box is not updated
  modelObject.updateInvisible = true
  
  -- Create a CrowdAgent component and set its height and realistic max speed/acceleration. Use default radius
  local agent = enemyNode:CreateComponent("CrowdAgent")
  agent.height = 2.0
  agent.maxSpeed = 3.0
  agent.maxAccel = 5.0

  -- Create a rigid body and a collision shape
  local body = enemyNode:CreateComponent("RigidBody")

  -- body should move freely in X and Z axis, but not Y, and shouldn't rotate due to physics
  body:SetMass(1.0)
  body:SetKinematic(true)
  body:SetCollisionLayer(COLLAYER_ENEMY)

  local shape = enemyNode:CreateComponent("CollisionShape")
  -- Create the capsule shape with an offset so that it is correctly aligned with the model, which
  -- has its origin at the feet
  shape:SetCapsule(0.7, 2.0, Vector3(0.0, 1.0, 0.0))

  local enemyFlashlightNode = enemyNode:GetChild("mixamorig:RightHand", true):CreateChild("EnemyFlashlight")

  -- create the enemy light!
  local enemyLightNode = enemyFlashlightNode:CreateChild("EnemyFlashlightLight")
  enemyLightNode.rotation = Quaternion(-62, 138.603, -13.9287)
  enemyLightNode.position = Vector3(0.0132837, 0.0864692, -0.0498416)
  local enemyLight = enemyLightNode:CreateComponent("Light")
  enemyLight.lightType = LIGHT_SPOT
  enemyLight.castShadows = false
--  enemyLight.shadowBias = BiasParameters(0.00025, 0.5)
  enemyLight:SetBrightness(3.5)
  enemyLight.range = ENEMY_LIGHT_RANGE
  enemyLight:SetFov(ENEMY_LIGHT_RADIUS * 2)
  
  -- create the visible light cone!
  local enemyLightConeNode = enemyLightNode:CreateChild("EnemyLightCone")
  
  enemyLightConeNode.rotation = Quaternion(-90.0, 0.0, 0.0)
  -- the cone model has its origin at the center, so we've got to move it around a little
  enemyLightConeNode.position = Vector3(0.0, 0.0, ENEMY_LIGHT_RANGE / 2)
  enemyLightConeNode.scale = Vector3(ENEMY_LIGHT_RADIUS / 4, ENEMY_LIGHT_RANGE, ENEMY_LIGHT_RADIUS / 4)
  local coneModel = enemyLightConeNode:CreateComponent("StaticModel")
  coneModel.model = cache:GetResource("Model", "Models/Cone.mdl")
  coneModel.material = cache:GetResource("Material", "Materials/Particle.xml")
  coneModel.lightMask = 0
  coneModel.shadowMask = 0
  
  
  -- add the "catch zone" to the cone
  local coneColl = enemyLightConeNode:CreateComponent("CollisionShape")
  coneColl:SetCone(1.0, 1.0)
  
  local coneBody = enemyLightConeNode:CreateComponent("RigidBody")
  coneBody.trigger = true
  coneBody.collisionMask = COLLAYER_PLAYER
  
  local enemyScript = enemyNode:CreateScriptObject("CinemaEnemy")
  table.insert(enemiesList, enemyScript)
  
end


CinemaSpawner = ScriptObject()

function CinemaSpawner:Start()
  
  self.timeSinceLastSpawn = 0.0
  
end

function CinemaSpawner:Update(timeStep)
  
  if game_over then return end
  
  self.timeSinceLastSpawn = self.timeSinceLastSpawn + timeStep
  
  if self.timeSinceLastSpawn > SPAWN_ENEMY_INTERVAL then
    CreateEnemy()
    self.timeSinceLastSpawn = 0.0
  end
  
end


