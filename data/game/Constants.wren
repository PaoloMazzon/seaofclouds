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
    static ALTERNATOR_TIME { 0.1 } // for flickering
    static SKY_COLOUR { [95 / 255, 205 / 255, 228 / 255, 255] }
    static PLAYER_SPEED { 100 }
    static CLOUD_COUNT { 30 } // must be even
    static SHAKE_INTENSITY { 3 }
    static FADE_TIME { 0.75 }
    static SKILL_CHECK_FADE_IN_TIME { 0.5 }
    static SKILL_CHECK_SPEED { Num.tau * 1.1 }
    static SKILL_CHECK_EASY { 1 }
    static SKILL_CHECK_HARD { 3 }
    static HIT_PAUSE { 0.2 }
    static TEAM_NONE { 0 }
    static TEAM_ENEMIES { 1 }
    static TEAM_PLAYER { 2 }
    static WEAPON_HIT_SHAKE { 0.1 }
    static PLAYER_PARRY_COOLDOWN { 2 }
    static PLAYER_PARRY_MOVEMENT_MODIFIER { 0.25 }
    static PLAYER_PARRY_IFRAMES { 1 } // time after a successful parry the player in invincible
}