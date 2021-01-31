local crowdManager = nil
local navMesh = nil

local WALKING_ANI = "Models/cinema_bump/character/Lanterninha Walking.ani"
local IDLE_ANI = "Models/cinema_bump/character/Lantertinha Idle.ani"

-- sets up the navigation system for the AI
function CreateEnemyNavSystem()
  -- Create a DynamicNavigationMesh component to the scene root
    navMesh = scene_:CreateComponent("DynamicNavigationMesh")
    
    -- Set small tiles to show navigation mesh streaming
    navMesh.tileSize = 64
    -- Enable drawing debug geometry for obstacles and off-mesh connections
    navMesh.drawObstacles = true
    -- Set the agent height large enough to exclude the layers under boxes
    navMesh.agentHeight = 10
    -- Set nav mesh cell height to minimum (allows agents to be grounded)
    navMesh.cellHeight = 0.05
    
    -- Now build the navigation geometry. This will take some time. Note that the navigation mesh will prefer to use
    -- physics geometry from the scene nodes, as it often is simpler, but if it can not find any (like in this example)
    -- it will use renderable geometry instead
    navMesh:Build(Vector2(-GAME_BOUNDS_X / 2, -GAME_BOUNDS_Z / 2), Vector2(GAME_BOUNDS_X / 2, GAME_BOUNDS_Z / 2))
    
    -- Create a CrowdManager component to the scene root (mandatory for crowd agents)
    crowdManager = scene_:CreateComponent("CrowdManager")
    local params = crowdManager:GetObstacleAvoidanceParams(0)
    -- Set the params to "High (66)" setting
    params.velBias = 0.5
    params.adaptiveDivs = 7
    params.adaptiveRings = 3
    params.adaptiveDepth = 3
    crowdManager:SetObstacleAvoidanceParams(0, params)
    
end

function HandleCrowdAgentReposition(eventType, eventData)
    

    local node = eventData["Node"]:GetPtr("Node")
    local agent = eventData["CrowdAgent"]:GetPtr("CrowdAgent")
    local velocity = eventData["Velocity"]:GetVector3()
    local timeStep = eventData["TimeStep"]:GetFloat()

    local animCtrl = node:GetComponent("AnimationController")
    if animCtrl ~= nil then
        local speed = velocity:Length()
        if animCtrl:IsPlaying(WALKING_ANI) then
            local speedRatio = speed / agent.maxSpeed
            -- Face the direction of its velocity but moderate the turning speed based on the speed ratio and timeStep
            node.rotation = node.rotation:Slerp(Quaternion(Vector3.FORWARD, velocity), 10.0 * timeStep * speedRatio)
            -- Throttle the animation speed based on agent speed ratio (ratio = 1 is full throttle)
            animCtrl:SetSpeed(WALKING_ANI, speedRatio * 1.5)
        else
            animCtrl:Play(WALKING_ANI, 0, true, 0.1)
        end

        -- If speed is too low then stop the animation
        if speed < agent.radius then
            animCtrl:Stop(WALKING_ANI, 0.5)
            animCtrl:Play(IDLE_ANI, 0, true, 0.2)
        end
    end
end

function HandleCrowdAgentFailure(eventType, eventData)
    local node = eventData["Node"]:GetPtr("Node")
    local agentState = eventData["CrowdAgentState"]:GetInt()

    -- If the agent's state is invalid, likely from spawning on the side of a box, find a point in a larger area
    if agentState == CA_STATE_INVALID then
        -- Get a point on the navmesh using more generous extents
        local newPos = navMesh:FindNearestPoint(node.position, Vector3(5, 5, 5))
        -- Set the new node position, CrowdAgent component will automatically reset the state of the agent
        node.position = newPos
    end
end

function GetRandomDestination()
  
  return crowdManager:GetRandomPoint()
  
end
