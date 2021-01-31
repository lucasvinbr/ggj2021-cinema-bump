-- collision layers!
COLLAYER_SCENARIO = 1
COLLAYER_PLAYER = 2
COLLAYER_ENEMY = 4

-- level boundaries
GAME_BOUNDS_X = 16.0
GAME_BOUNDS_Z = 16.0

SPAWN_ENEMY_INTERVAL = 8.0

ENEMY_LIGHT_RANGE = 5.0
ENEMY_LIGHT_RADIUS = 15.0

drawDebug = false -- Draw debug geometry flag

game_over = false -- game over flag

-- multiplier over how fast the player's trouble level reduces with time when he's not acting
TROUBLE_DECAY_SPEED_MULT = 4.0
TROUBLE_LEVEL_MAX = 30.0
TROUBLE_INTENSITY_MAX = 5 -- shorthand; can be inferred from trouble level max

PLAYER_TROUBLESOUND_BASE_INTERVAL = 2.0 -- base interval between annoying sounds, reduced as the trouble intensity grows
PLAYER_TROUBLESOUND_INTERVAL_REDUCTION_PER_INTENSITY = 0.35