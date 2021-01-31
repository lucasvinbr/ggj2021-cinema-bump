local window = nil
local centerPivot = Vector2(0.5,0.5)

local scoreText = nil
local hiScoreText = nil

function CreateUI()
  
  -- Load XML file containing default UI style sheet
    local style = cache:GetResource("XMLFile", "UI/DefaultStyle.xml")

    -- Set the loaded style as default style
    ui.root.defaultStyle = style
    

    -- Create the Window and add it to the UI's root node
    window = UIElement:new()
    ui.root:AddChild(window)

    scoreText = Text:new()
    scoreText.text = "0"
    scoreText:SetAlignment(HA_RIGHT, VA_BOTTOM)
    ui.root:AddChild(scoreText)
    scoreText:SetStyleAuto()
    scoreText:SetFontSize(30.0)
    
    hiScoreText = Text:new()
    hiScoreText.text = "0"
    hiScoreText:SetAlignment(HA_CENTER, VA_TOP)
    ui.root:AddChild(hiScoreText)
    hiScoreText:SetStyleAuto()
    hiScoreText:SetFontSize(50.0)
    
    -- Set Window size and layout settings
    window.minWidth = 384
    window:SetLayout(LM_VERTICAL, 6, IntRect(6, 6, 6, 6))
    window:SetAlignment(HA_CENTER, VA_CENTER)
    window:SetName("Window")

    -- Create Window 'titlebar' container
    local titleBar = UIElement:new()
    titleBar:SetMinSize(0, 60)
    titleBar:SetAlignment(HA_CENTER, VA_CENTER)
    titleBar.layoutMode = LM_HORIZONTAL

    -- Create the Window title Text
    local windowTitle = Text:new()
    windowTitle.name = "WindowTitle"
    windowTitle.text = "CINEMA BUMP"
    windowTitle:SetAlignment(HA_CENTER, VA_CENTER)
    windowTitle:SetTextAlignment(HA_CENTER)
    
    local playBtnText = Text:new()
    playBtnText.text = "PLAY"
    playBtnText:SetAlignment(HA_CENTER, VA_CENTER)
    playBtnText:SetTextAlignment(HA_CENTER)
    
    local closeBtnText = Text:new()
    closeBtnText.text = "EXIT"
    closeBtnText:SetAlignment(HA_CENTER, VA_CENTER)
    closeBtnText:SetTextAlignment(HA_CENTER)

    
    -- create window's buttons column
    local buttonsContainer = UIElement:new()
    buttonsContainer:SetAlignment(HA_CENTER, VA_CENTER)
    buttonsContainer:SetLayout(LM_VERTICAL, 6, IntRect(6, 6, 6, 6))
    
    
    -- Create the Window's close button
    local buttonClose = Button:new()
    buttonClose:SetName("CloseButton")
    buttonClose:SetMaxSize(250, 60)
    buttonClose:SetMinSize(250, 60)
    buttonClose:SetAlignment(HA_CENTER, VA_CENTER)
--    buttonClose:SetLayout(LM_VERTICAL, 0, IntRect(6, 6, 6, 6))
    
    local buttonPlay = Button:new()
    buttonPlay:SetName("PlayButton")
    buttonPlay:SetMaxSize(250, 60)
    buttonPlay:SetMinSize(250, 60)
    buttonPlay:SetAlignment(HA_CENTER, VA_CENTER)
--    buttonPlay:SetLayout(LM_VERTICAL, 0, IntRect(6, 6, 6, 6))

    -- Add the controls to the title bar
    titleBar:AddChild(windowTitle)
    buttonClose:AddChild(closeBtnText)
    buttonPlay:AddChild(playBtnText)
    buttonsContainer:AddChild(buttonPlay)
    buttonsContainer:AddChild(buttonClose)

    -- Add the title bar to the Window
    window:AddChild(titleBar)
    window:AddChild(buttonsContainer)

    -- Apply styles
    windowTitle:SetStyleAuto()
    playBtnText:SetStyleAuto()
    closeBtnText:SetStyleAuto()
    
    windowTitle:SetFontSize(100.0)
    
    buttonClose:SetStyleAuto()
    buttonPlay:SetStyleAuto()
    

    -- Subscribe to buttonClose release (following a 'press') events
    SubscribeToEvent(buttonClose, "Released",
        function (eventType, eventData)
            engine:Exit()
        end)
  
    -- Subscribe to buttonClose release (following a 'press') events
    SubscribeToEvent(buttonPlay, "Released",
        function (eventType, eventData)
            StartGame()
            
            ToggleMainMenu(false)
        end)
end

function SetScoreText(newValue)
  
  scoreText.text = newValue
  
end

function SetHiScoreText(newValue)
  
  hiScoreText.text = "HI-SCORE: ".. newValue
  
end


function ToggleMainMenu(display)
  
  window:SetFocus(display)
  window:SetVisible(display)
  hiScoreText:SetVisible(display)
  SetHiScoreText(score_handler.score_high)
  
  if display then
    SetMouseMode(MM_FREE)
  else
    SetMouseMode(MM_RELATIVE)
  end
  
end
