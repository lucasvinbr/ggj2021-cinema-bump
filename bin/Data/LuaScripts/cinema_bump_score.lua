score_handler = nil

function SetupScore()
  score_handler = scene_:CreateScriptObject("CinemaScore")
end

CinemaScore = ScriptObject()

function CinemaScore:Start()
  self.score_current = 0
  
  local scorefile = io.open("hiscore.txt", "r")
  if scorefile ~= nil then
    self.score_high = tonumber(scorefile:read())
    scorefile:close()
  else
    self.score_high = 0
  end
end

function CinemaScore:SaveScores()
  if self.score_current > self.score_high then 
    self.score_high = self.score_current 
  end
  self.score_current = 0
  
  local scorefile = io.open("hiscore.txt", "w+")
  scorefile:write(self.score_high)
  scorefile:close()
  
end

-- returns true if the score has changed
function CinemaScore:IncrementScore(increment)

  if increment <= 0 then return false end

  self.score_current = self.score_current + increment
  SetScoreText(self.score_current)

  return true
end

function CinemaScore:ResetScore()

  self.score_current = 0
  SetScoreText(self.score_current)

end