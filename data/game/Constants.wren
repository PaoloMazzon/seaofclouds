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
    static ISLAND_RADIUS_MAX                { [10, 10, 10, 10, 10, 10] }
    static ISLAND_RADIUS_MIN                { [ 3,  3,  3,  3,  3,  3] }
    static ISLAND_MINIMUM_DISTANCE          { [15, 15, 15, 15, 15, 15] }
    static LEVEL_WIDTH                      { [50, 75, 75, 75, 75, 75] }
    static LEVEL_HEIGHT                     { [50, 75, 75, 75, 75, 75] }
    static LEVEL_ISLAND_COUNT               { [13, 13, 13, 13, 13, 13] }
    static LEVEL_ENEMY_MAX                  { [20, 20, 20, 20, 20, 20] }
    static LEVEL_ENEMY_MIN                  { [15, 15, 15, 15, 15, 15] }
    static LEVEL_TRAP_MAX                   { [ 0, 10, 10, 10, 10, 10] }
    static LEVEL_TRAP_MIN                   { [ 0,  5,  5,  5,  5,  5] }
    static LEVEL_ENVIRONMENT_STRUCTURES_MAX { [15, 30, 20, 20, 20, 20] }
    static LEVEL_ENVIRONMENT_STRUCTURES_MIN { [ 8, 15, 12, 12, 12, 12] }

    //////////////////////////// Player base values ////////////////////////////
    static PLAYER_PARRY_COOLDOWN { 2 }
    static PLAYER_PARRY_MOVEMENT_MODIFIER { 0.25 }
    static PLAYER_PARRY_IFRAMES { 1 } // amount of time after a successful parry the player is invincible
    static THROWING_AXE_SPEED { 150 }
    static THROWING_AXE_DECELERATION { 50 }
    static PLAYER_SPEED { 100 }

    //////////////////////////// Items ////////////////////////////
    static ITEM_DASH_SPEED { 150 }
    static ITEM_DASH_DURATION { 0.5 }
    static ITEM_BOOTS_SPEED { 8 }
    static ITEMS_WHETSTONE_FACTOR { 0.90 } // percent of parry cooldown to keep
    static ITEMS_MAGNET_AXE_SPEED { 20 } // how fast the axe returns to you

    //////////////////////////// NPC balance ////////////////////////////
    static NPC_TOP_SPEED { 40 }
    static NPC_MAX_WANDER_DISTANCE { 75 }
    static NPC_SCORE_VALUE { 10 }
    static NPC_GIVE_ITEM_SCORE { 50 }

    //////////////////////////// Trap balance ////////////////////////////
    static SPIKES_DELAY { 0.5 }

    //////////////////////////// Slime balance ////////////////////////////
    static SLIME_TOP_SPEED { 70 }
    static SLIME_AGGRO_RANGE { 75 }
    static SLIME_SCORE_VALUE { 5 }

    //////////////////////////// Ranger balance ////////////////////////////
    static RANGER_WALK_SPEED { 50 }
    static RANGER_RUN_SPEED { 80 }
    static RANGER_AGGRO_RANGE { 100 }
    static RANGER_ARROW_SPEED { 200 }
    static RANGER_ARROW_LIFETIME { 3 }
    static RANGER_MIN_SHOOT_COOLDOWN { 0.75 } // time between shots
    static RANGER_MAX_SHOOT_COOLDOWN { 1.5 }
    static RANGER_SEARCH_TIME_MIN { 3 }
    static RANGER_SEARCH_TIME_MAX { 5 }
    static RANGER_INITIAL_SHOT_DELAY { 1 } // how long after seeing the player it will wait before shooting
    static RANGER_SCORE_VALUE { 15 }

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
    static WIZARD_SCORE_VALUE { 40 }
}