require "LuaScripts/cinema_bump_rules"
require "LuaScripts/cinema_bump_debug"
require "LuaScripts/cinema_bump_enemy"
require "LuaScripts/cinema_bump_light"
require "LuaScripts/cinema_bump_mouse"
require "LuaScripts/cinema_bump_navigation"
require "LuaScripts/cinema_bump_player"
require "LuaScripts/cinema_bump_troublemeter"
require "LuaScripts/cinema_bump_spawner"
require "LuaScripts/cinema_bump_ui"
require "LuaScripts/cinema_bump_audio"
require "LuaScripts/cinema_bump_score"

scene_ = nil -- Scene
cameraNode = nil -- Camera scene node


function Start()
  
  SetRandomSeed(os.time())
  -- Set custom window Title & Icon
  SetWindowTitleAndIcon()
  
  -- Execute debug stuff startup
  DebugSetup()

  -- Create the scene content
  CreateScene()
  
  SetupScore()
  
  CreateEnemyNavSystem()

  -- Setup the viewport for displaying the scene
  SetupViewport()
  
  CreateUI()
  
  SetupSound()
  
  -- Hook up to relevant events
  SubscribeToEvents()
  
  ToggleMainMenu(true)
    
end

function SetWindowTitleAndIcon()
    local icon = cache:GetResource("Image", "Textures/UrhoIcon.png")
    graphics:SetWindowIcon(icon)
    graphics.windowTitle = "Vrau"
end

function CreateChairBatch(position)
  CreateChair(Vector3(position.x - 1,position.y,position.z))
  CreateChair(position)
  CreateChair(Vector3(position.x + 1,position.y,position.z))

  CreateChair(Vector3(position.x - 1,position.y,position.z-1.5))
  CreateChair(Vector3(position.x,position.y,position.z-1.5))
  CreateChair(Vector3(position.x + 1,position.y,position.z-1.5))

  CreateChair(Vector3(position.x - 1,position.y,position.z + 1.5))
  CreateChair(Vector3(position.x,position.y,position.z + 1.5))
  CreateChair(Vector3(position.x + 1,position.y,position.z + 1.5))
end

function CreateScene()
  scene_ = Scene()

  -- Create octree, use default volume (-1000, -1000, -1000) to (1000, 1000, 1000)
  -- Create a physics simulation world with default parameters, which will update at 60fps. Like the Octree must
  -- exist before creating drawable components, the PhysicsWorld must exist before creating physics components.
  -- Finally, create a DebugRenderer component so that we can draw physics debug geometry
  scene_:CreateComponent("Octree")
  scene_:CreateComponent("PhysicsWorld")
  scene_:CreateComponent("DebugRenderer")

  -- Create a Zone component for ambient lighting & fog control
  local zoneNode = scene_:CreateChild("Zone")
  local zone = zoneNode:CreateComponent("Zone")
  zone.boundingBox = BoundingBox(-1000.0, 1000.0)
  zone.ambientColor = Color(0.1, 0.1, 0.1)
  zone.fogColor = Color(0.0, 0.0, 0.0)
  zone.fogStart = 1.0
  zone.fogEnd = GAME_BOUNDS_Z * 2

  -- Create floor and walls!
  -- start with the invisible wall, from which the player will see the game
  local cameraWallNode = scene_:CreateChild("Wall")
  cameraWallNode.scale = Vector3(500.0, 500.0, 1.0)
  cameraWallNode.position = Vector3(0.0, 0.0, -GAME_BOUNDS_Z / 2)

  -- Make the wall physical by adding RigidBody and CollisionShape components
  local body = cameraWallNode:CreateComponent("RigidBody")
  body.collisionLayer = COLLAYER_SCENARIO
  local shape = cameraWallNode:CreateComponent("CollisionShape")
  -- Set a box shape of size 1 x 1 x 1 for collision. The shape will be scaled with the scene node scale
  shape:SetBox(Vector3(1.0, 1.0, 1.0))


  local wallsNode = cameraWallNode:Clone()
  wallsNode.scale = Vector3.ONE
  wallsNode.position = Vector3.ZERO

  --add a model to the visible walls
  local wallsModel = wallsNode:CreateComponent("StaticModel")
  wallsModel.model = cache:GetResource("Model", "Models/cinema_bump/walls.mdl")
  wallsModel.material = cache:GetResource("Material", "Materials/cinema_bump/walls_material.xml")

  -- setup wall colliders
  local rightWallColl = wallsNode:GetComponent("CollisionShape")
  rightWallColl:SetBox(Vector3(0.25, 15.0, 15.0), Vector3(7.5, 0.0, 0.0), Quaternion.IDENTITY)

  local leftWallColl = wallsNode:CreateComponent("CollisionShape")
  leftWallColl:SetBox(Vector3(0.25, 15.0, 15.0), Vector3(-7.5, 0.0, 0.0), Quaternion.IDENTITY)
  
  local backWallColl = wallsNode:CreateComponent("CollisionShape")
  backWallColl:SetBox(Vector3(15.0, 15.0, 0.25), Vector3(0.0, 0.0, 7.5), Quaternion.IDENTITY)

  local floorNode = cameraWallNode:Clone()
  floorNode.position = Vector3.ZERO
  
  floorNode.scale = Vector3.ONE
  
  local floorModel = floorNode:CreateComponent("StaticModel")
  floorModel.model = cache:GetResource("Model", "Models/cinema_bump/floor.mdl")
  floorModel.material = cache:GetResource("Material", "Materials/cinema_bump/floor_material.xml")

  local floorColl = floorNode:GetComponent("CollisionShape")
  floorColl:SetBox(Vector3(15.0, 0.2, 15.0))
  

  --set floor node as the only one used for AI navigation
  floorNode:CreateComponent("Navigable")
  wallsNode:CreateComponent("Navigable")
  
  -- and the chairs!
  CreateChairBatch(Vector3(0, 0, 1))
  CreateChairBatch(Vector3(5, 0, 1))
  CreateChairBatch(Vector3(-5, 0, 1))
  --
  -- CreateChairBatch(Vector3(0, 0, 5))
  -- CreateChairBatch(Vector3(5, 0, 5))
  -- CreateChairBatch(Vector3(-5, 0, 5))
  --
  CreateChairBatch(Vector3(0, 0, -5))
  CreateChairBatch(Vector3(5, 0, -5))
  CreateChairBatch(Vector3(-5, 0, -5))

  -- Create doors
  local doorsNode = scene_:CreateChild("Doors")
  local doors = doorsNode:CreateComponent("StaticModel")
  doors.model = cache:GetResource("Model", "Models/cinema_bump/doors.mdl")
  doors.material = cache:GetResource("Material", "Materials/cinema_bump/doors_material.xml")
  

  -- Create the camera. Limit far clip distance to match the fog. Note: now we actually create the camera node outside
  -- the scene, because we want it to be unaffected by scene load / save
  cameraNode = Node()
  local camera = cameraNode:CreateComponent("Camera")
  camera.farClip = 300.0
  camera:SetFov(56.0)

  -- Set an initial position for the camera scene: a little "behind" the invisible wall, so that the bounds are more clearly visible
  cameraNode.position = Vector3(0.0, 5.0, (-GAME_BOUNDS_Z / 2) - 2.5)
  cameraNode.rotation = Quaternion(25.0, 0.0, 0.0)
  
  CreateCinemaLight()
  
end


function SetupViewport()
  -- Set up a viewport to the Renderer subsystem so that the 3D scene can be seen
  local viewport = Viewport:new(scene_, cameraNode:GetComponent("Camera"))
  renderer:SetViewport(0, viewport)
end

function SubscribeToEvents()
  -- Subscribe HandleUpdate() function for processing update events
--    SubscribeToEvent("Update", "HandleUpdate")

  -- Subscribe HandlePostRenderUpdate() function for processing the post-render update event, during which we request
  -- debug geometry
  SubscribeToEvent("PostRenderUpdate", "HandlePostRenderUpdate")
  
  -- Subscribe HandleCrowdAgentFailure() function for resolving invalidation issues with agents, during which we
  -- use a larger extents for finding a point on the navmesh to fix the agent's position
  SubscribeToEvent("CrowdAgentFailure", "HandleCrowdAgentFailure")

  -- Subscribe HandleCrowdAgentReposition() function for controlling the animation
  SubscribeToEvent("CrowdAgentReposition", "HandleCrowdAgentReposition")
end


function HandlePostRenderUpdate(eventType, eventData)
  -- If draw debug mode is enabled, draw physics debug geometry. Use depth test to make the result easier to interpret
  if drawDebug then
    scene_:GetComponent("PhysicsWorld"):DrawDebugGeometry(true)
    -- Visualize navigation mesh, obstacles and off-mesh connections
    scene_:GetComponent("DynamicNavigationMesh"):DrawDebugGeometry(true)
    -- Visualize agents' path and position to reach
    scene_:GetComponent("CrowdManager"):DrawDebugGeometry(true)
  end
end
