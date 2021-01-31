local playerSfxNames = {
  "Sounds/cinema_bump/Funny1.wav",
  "Sounds/cinema_bump/Funny2.wav",
  "Sounds/cinema_bump/Funny3.wav",
  "Sounds/cinema_bump/Funny4.wav",
  "Sounds/cinema_bump/Funny5.wav",
  "Sounds/cinema_bump/Funny6.wav",
}

local musicNames = {
  "Music/cinema_bump/western.ogg",
  "Music/cinema_bump/horror.ogg",
  "Music/cinema_bump/spy.ogg"
}

local youLoseSoundName = "Sounds/cinema_bump/slipperyBanana.wav"
local scoreSoundName = "Sounds/cinema_bump/tectec.wav"

musicSource = nil

function SetupSound()

  -- Create music sound source
  musicSource = scene_:CreateComponent("SoundSource")
  -- Set the sound type to music so that master volume control works correctly
  musicSource.soundType = SOUND_MUSIC

  -- add listener to camera
  local listener = cameraNode:CreateComponent("SoundListener")
  audio:SetListener(listener)

  PlayRandomMusic()

  SubscribeToEvent("SoundFinished", "OnSoundFinished")

end

function OnSoundFinished(eventType, eventData)

  if eventData["SoundSource"]:GetPtr("SoundSource") == musicSource then
    PlayRandomMusic()
  end

end


function PlayRandomMusic()

  musicSource:Play(cache:GetResource("Sound", musicNames[RandomInt(1, #musicNames + 1)]))

end

function PlayPlayerSound(audioSource)

  audioSource:Play(cache:GetResource("Sound", playerSfxNames[RandomInt(1, #playerSfxNames + 1)]), Random(33000.0, 66000.0))

end

function PlayScoreSound(audioSource)

  audioSource:Play(cache:GetResource("Sound", scoreSoundName))

  end

  function PlayYouLoseSound(audioSource)

    audioSource:Play(cache:GetResource("Sound", youLoseSoundName, Random(39000.0, 60000.0)))

    end

    function HandlePlaySound(sender, eventType, eventData)
      local button = tolua.cast(GetEventSender(), "Button")
      local soundResourceName = button:GetVar(StringHash("SoundResource")):GetString()

      -- Get the sound resource
      local sound = cache:GetResource("Sound", soundResourceName)

      if sound ~= nil then
        -- Create a SoundSource component for playing the sound. The SoundSource component plays
        -- non-positional audio, so its 3D position in the scene does not matter. For positional sounds the
        -- SoundSource3D component would be used instead
        local soundSource = scene_:CreateComponent("SoundSource")
        soundSource:SetAutoRemoveMode(REMOVE_COMPONENT)
        soundSource:Play(sound)
        -- In case we also play music, set the sound volume below maximum so that we don't clip the output
        soundSource.gain = 0.7
      end
    end

    function HandlePlayMusic(eventType, eventData)
      local music = cache:GetResource("Sound", "Music/Ninja Gods.ogg")
      -- Set the song to loop
      music.looped = true

      musicSource:Play(music)
    end

    function HandleStopMusic(eventType, eventData)
      musicSource:Stop()
    end

    function HandleSoundVolume(eventType, eventData)
      local newVolume = eventData["Value"]:GetFloat()
      audio:SetMasterGain(SOUND_EFFECT, newVolume)
    end

    function HandleMusicVolume(eventType, eventData)
      local newVolume = eventData["Value"]:GetFloat()
      audio:SetMasterGain(SOUND_MUSIC, newVolume)
    end
