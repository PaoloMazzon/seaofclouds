// Speeds are in unit/seconds and time is all seconds
class Constants {
    //////////////////////////// Internal ////////////////////////////
    static GAME_WIDTH { 300.0 }
    static GAME_HEIGHT { 200.0 }
    static CONTROL_LEFT { 0 }
    static CONTROL_RIGHT { 3 }
    static CONTROL_UP { 1 }
    static CONTROL_DOWN { 2 }
    static CONTROL_ATTACK { 4 }
    static CONTROL_PARRY { 5 }
    static CONTROL_THROW { 6 }
    static CONTROL_CONFIRM { 7 }
    static CONTROL_RESTART { 8 }
    static SKILL_CHECK_EASY { 1 }
    static SKILL_CHECK_HARD { 3 }
    static TEAM_NONE { 0 }
    static TEAM_ENEMIES { 1 }
    static TEAM_PLAYER { 2 }
    static TEAM_TRAPS { 3 }
    static FLOATING_TEXT_DURATION { 2 }

    //////////////////////////// Graphics ////////////////////////////
    static ALTERNATOR_TIME { 0.1 } // for flickering
    static SKY_COLOUR { [0, 0, 0, 1] }
    static FADE_TIME { 0.75 }
    static CLOUD_COUNT { 30 } // must be even
    static MIN_PROPS { 30 }
    static MAX_PROPS { 50 }
    static MAX_STRUCTURES { 5 }
    static MIN_STRUCTURES { 3 }

    //////////////////////////// Balance ////////////////////////////
    static SKILL_CHECK_FADE_IN_TIME { 0.5 }
    static SKILL_CHECK_SPEED { Num.tau * 1.1 }
    static HIT_PAUSE { 0.2 }
    static WEAPON_HIT_SHAKE { 0.1 }
    static SPAWN_GRACE_RANGE { 8 } // how far enemies must be from player spawn in tiles (24*16)
    static ENEMY_HIT_IFRAMES { 1 }

    //////////////////////////// Level generation by stage ////////////////////////////
    static ISLAND_RADIUS_MAX                { [10, 10, 11, 12, 12, 0] }
    static ISLAND_RADIUS_MIN                { [ 3,  3,  4,  8,  6, 0] }
    static ISLAND_MINIMUM_DISTANCE          { [15, 15, 15, 35, 20, 0] }
    static LEVEL_WIDTH                      { [50, 75, 75, 80, 99, 0] }
    static LEVEL_HEIGHT                     { [50, 75, 75, 80, 99, 0] }
    static LEVEL_ISLAND_COUNT               { [13, 13, 11, 10, 20, 0] }
    static LEVEL_ENEMY_MAX                  { [15, 20, 25, 25, 40, 0] }
    static LEVEL_ENEMY_MIN                  { [10, 15, 15, 10, 30, 0] }
    static LEVEL_RANDOM_CHEST_MAX           { [ 1,  2,  2,  2,  3, 0] }
    static LEVEL_RANDOM_CHEST_MIN           { [ 0,  1,  1,  1,  1, 0] }
    static LEVEL_TRAP_MAX                   { [ 5, 10, 15, 15, 20, 0] }
    static LEVEL_TRAP_MIN                   { [ 2,  5,  8, 10, 15, 0] }
    static LEVEL_ENVIRONMENT_STRUCTURES_MAX { [15, 60, 45, 40, 60, 0] }
    static LEVEL_ENVIRONMENT_STRUCTURES_MIN { [ 8, 30, 25, 30, 40, 0] }
    static LEVEL_TRAIL_COUNT_MIN            { [ 1,  1,  1,  1,  1, 0] } // trails are always only 1 right now
    static LEVEL_TRAIL_COUNT_MAX            { [ 2,  3,  3,  4,  4, 0] } // trails are always only 1 right now

    //////////////////////////// Player base values ////////////////////////////
    static PLAYER_PARRY_COOLDOWN { 2 }
    static PLAYER_PARRY_MOVEMENT_MODIFIER { 0.25 }
    static PLAYER_PARRY_IFRAMES { 1 } // amount of time after a successful parry the player is invincible
    static THROWING_AXE_SPEED { 150 }
    static THROWING_AXE_DECELERATION { 50 }
    static PLAYER_SPEED { 75 }
    static PLAYER_DIALOGUE_CHANCE { 0.1 }
    static PLAYER_DIALOGUE {[
        "\"What the heck is a wenrad?\"",
        "\"Those ladders are strange.\"",
        "\"Why are we here?\"",
        "\"No one's gonna believe me...\"",
        "\"Am I in control?\"",
        "\"I miss my forge.\"",
        "\"How'd everyone else get here?\"",
        "\"...\"",
    ]}

    //////////////////////////// Items ////////////////////////////
    static ITEM_DASH_SPEED { 150 }
    static ITEM_DASH_DURATION { 0.5 }
    static ITEM_BOOTS_SPEED { 8 }
    static ITEMS_WHETSTONE_FACTOR { 0.90 } // percent of parry cooldown to keep
    static ITEMS_MAGNET_AXE_SPEED { 20 } // how fast the axe returns to you
    static ITEM_GLASS_ZOOM_FACTOR { 0.95 } // how far zoomed out you get from a glass
    static RARE_ITEM_CHANCE { 0.1 }

    //////////////////////////// NPC balance ////////////////////////////
    static NPC_TOP_SPEED { 40 }
    static NPC_MAX_WANDER_DISTANCE { 75 }
    static NPC_SCORE_VALUE { 10 }
    static NPC_GIVE_ITEM_SCORE { 50 }

    //////////////////////////// Trap balance ////////////////////////////
    static SPIKES_DELAY { 0.5 }
    static FAST_SPIKES_DELAY { 0.2 }
    static PLANT_TRAP_DETONATION_TIMER { 1 }

    //////////////////////////// Slime balance ////////////////////////////
    static SLIME_TOP_SPEED { 70 }
    static SLIME_AGGRO_RANGE { 75 }
    static SLIME_MIN_MOVE_TIME { 0.75 } // min/max time between the slime deciding to move or attack
    static SLIME_MAX_MOVE_TIME { 2.5 }
    static SLIME_EXTRA_LIVES { 0 }
    static SLIME_SCORE_VALUE { 5 }

    //////////////////////////// Ranger balance ////////////////////////////
    static RANGER_WALK_SPEED { 50 }
    static RANGER_RUN_SPEED { 80 }
    static RANGER_AGGRO_RANGE { 100 }
    static RANGER_ARROW_SPEED { 200 }
    static RANGER_ARROW_LIFETIME { 3 }
    static RANGER_MIN_SHOOT_COOLDOWN { 1.5 } // time between shots
    static RANGER_MAX_SHOOT_COOLDOWN { 2 }
    static RANGER_SEARCH_TIME_MIN { 3 }
    static RANGER_SEARCH_TIME_MAX { 5 }
    static RANGER_INITIAL_SHOT_DELAY { 1.5 } // how long after seeing the player it will wait before shooting
    static RANGER_EXTRA_LIVES { 0 }
    static RANGER_SCORE_VALUE { 15 }

    //////////////////////////// Rogue balance ////////////////////////////
    static ROGUE_WALK_SPEED { 50 }
    static ROGUE_RUN_SPEED { 80 }
    static ROGUE_CHARGE_SPEED { 105 }
    static ROGUE_CHARGE_TIME { 1 }
    static ROGUE_AGGRO_RANGE { 80 }
    static ROGUE_AGGRO_RANGE_IN_FIGHT { 140 } // how far their aggro range is while engaged with the player
    static ROGUE_MIN_CIRCLE_TIME { 1 } // time spent circling around the player
    static ROGUE_MAX_CIRCLE_TIME { 2 }
    static ROGUE_SEARCH_TIME_MIN { 3 }
    static ROGUE_SEARCH_TIME_MAX { 5 }
    static ROGUE_CIRCLE_DISTANCE { 50 } // distance from the player while circling
    static ROGUE_SCORE_VALUE { 55 }
    static ROGUE_BOMB_TIMER { 4 } // how long between rogue bomb throws
    static ROGUE_BOMB_DETONATION_TIMER { 1 } // how long it takes the bombs to explode
    static ROGUE_BOMB_CHANCE { 0.75 } // percent chance the rogue will throw a bomb if they are allowed to (bomb timer is up)
    static ROGUE_EXTRA_LIVES { 1 }

    //////////////////////////// Wizard balance ////////////////////////////
    static WIZARD_WALK_SPEED { 30 }
    static WIZARD_RUN_SPEED { 50 }
    static WIZARD_AGGRO_RANGE { 80 }
    static WIZARD_FIREBALL_SPEED { 140 }
    static WIZARD_FIREBALL_LIFETIME { 3 }
    static WIZARD_MIN_SHOOT_COOLDOWN { 1 } // time between shots
    static WIZARD_MAX_SHOOT_COOLDOWN { 2 }
    static WIZARD_SEARCH_TIME_MIN { 3 }
    static WIZARD_SEARCH_TIME_MAX { 5 }
    static WIZARD_INITIAL_SHOT_DELAY { 1 } // how long after seeing the player it will wait before shooting
    static WIZARD_EXTRA_LIVES { 0 }
    static WIZARD_SCORE_VALUE { 40 }

    //////////////////////////// Fighter balance ////////////////////////////
    static FIGHTER_WALK_SPEED { 50 }
    static FIGHTER_RUN_SPEED { 80 }
    static FIGHTER_CHARGE_SPEED { 105 }
    static FIGHTER_CHARGE_TIME { 1 }
    static FIGHTER_AGGRO_RANGE { 80 }
    static FIGHTER_AGGRO_RANGE_IN_FIGHT { 140 } // how far their aggro range is while engaged with the player
    static FIGHTER_MIN_CIRCLE_TIME { 1 } // time spent circling around the player
    static FIGHTER_MAX_CIRCLE_TIME { 2 }
    static FIGHTER_SEARCH_TIME_MIN { 3 }
    static FIGHTER_SEARCH_TIME_MAX { 5 }
    static FIGHTER_CIRCLE_DISTANCE { 50 } // distance from the player while circling
    static FIGHTER_EXTRA_LIVES { 1 }
    static FIGHTER_SCORE_VALUE { 20 }

    //////////////////////////// Hunter balance ////////////////////////////
    static HUNTER_WALK_SPEED { 50 }
    static HUNTER_RUN_SPEED { 80 }
    static HUNTER_CHARGE_SPEED { 105 }
    static HUNTER_CHARGE_TIME { 1 }
    static HUNTER_AGGRO_RANGE { 80 }
    static HUNTER_AGGRO_RANGE_IN_FIGHT { 140 } // how far their aggro range is while engaged with the player
    static HUNTER_MIN_CIRCLE_TIME { 1 } // time spent circling around the player
    static HUNTER_MAX_CIRCLE_TIME { 2 }
    static HUNTER_SEARCH_TIME_MIN { 3 }
    static HUNTER_SEARCH_TIME_MAX { 5 }
    static HUNTER_CIRCLE_DISTANCE { 50 } // distance from the player while circling
    static HUNTER_EXTRA_LIVES { 2 }
    static HUNTER_ENTER_CIRCLING { 80 } // how far from the player the hunter has to be to be in the cirlcing state
    static HUNTER_SCORE_VALUE { 50 }

    //////////////////////////// Alien balance ////////////////////////////
    static ALIEN_WALK_SPEED { 50 }
    static ALIEN_RUN_SPEED { 70 }
    static ALIEN_CHARGE_SPEED { 105 }
    static ALIEN_CHARGE_TIME { 1 }
    static ALIEN_MIN_CIRCLE_TIME { 2 } // time spent circling around the player
    static ALIEN_MAX_CIRCLE_TIME { 3 }
    static ALIEN_AGGRO_RANGE_IN_FIGHT { 140 } // how far their aggro range is while engaged with the player
    static ALIEN_CIRCLE_DISTANCE { 50 } // distance from the player while circling
    static ALIEN_EXTRA_LIVES { 0 }
    static ALIEN_ENTER_CIRCLING { 80 } // how far from the player the hunter has to be to be in the cirlcing state
    static ALIEN_SCORE_VALUE { 20 }

    //////////////////////////// Boss balance ////////////////////////////
    static BOSS_WALK_SPEED { 50 } // For run and gun
    static BOSS_CHARGE_SPEED { 140 } // For melee attacks
    static BOSS_CHARGE_TIME { 5 } // how long to charge at the player for
    static BOSS_BULLET_LIFETIME { 3 }
    static BOSS_BULLET_SPEED { 350 }
    static BOSS_PHASE_COOLDOWN_TIME_MIN { 3 }
    static BOSS_PHASE_COOLDOWN_TIME_MAX { 5 }
    static BOSS_PHASE_MELEE_MODIFIER { 0.6 } // Percent of the actual cooldown to wait after a melee since theyre easier
    static BOSS_MIN_SHOOT_DISTANCE { 40 } // How close to run to the player while shooting
    static BOSS_EXTRA_LIVES { 11 }
    static BOSS_SCORE_VALUE { 250 }
    static BOSS_ALIEN_SPAWN_COUNT { [1, 2, 2, 2, 3] } // one of these values will be chosen randomly
    static BOSS_ALIEN_SPAWN_RADIUS { 40 }
    static BOSS_IFRAMES { 2 }
}