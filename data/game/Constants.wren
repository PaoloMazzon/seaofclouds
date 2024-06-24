class Constants {
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
    static ALTERNATOR_TIME { 0.1 } // for flickering
    static SKY_COLOUR { [95 / 255, 205 / 255, 228 / 255, 255] }
    static FADE_TIME { 0.75 }
    static CLOUD_COUNT { 30 } // must be even
    static SKILL_CHECK_EASY { 1 }
    static SKILL_CHECK_HARD { 3 }
    static TEAM_NONE { 0 }
    static TEAM_ENEMIES { 1 }
    static TEAM_PLAYER { 2 }

    //////////////////////////// Balance ////////////////////////////
    // Speeds are in unit/seconds and time is all seconds
    static PLAYER_SPEED { 100 }
    static SHAKE_INTENSITY { 3 }
    static SKILL_CHECK_FADE_IN_TIME { 0.5 }
    static SKILL_CHECK_SPEED { Num.tau * 1.1 }
    static HIT_PAUSE { 0.2 }
    static WEAPON_HIT_SHAKE { 0.1 }
    static PLAYER_PARRY_COOLDOWN { 2 }
    static PLAYER_PARRY_MOVEMENT_MODIFIER { 0.25 }
    static PLAYER_PARRY_IFRAMES { 1 } // time after a successful parry the player in invincible
    static SPAWN_GRACE_RANGE { 8 } // how far enemies must be from player spawn

    // Ops
    static SLIME_TOP_SPEED { 70 }
    static SLIME_AGGRO_RANGE { 75 }
}