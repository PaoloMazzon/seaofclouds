import "random" for Random

// Generates a random sky level and returns the grid
class Generator {
    static GROUND_TILES { [1, 2, 3, 4] }
    static DROP_TILES { [5, 6, 7, 8] }
    static DECORATION_TILES { [31, 32, 33, 34, 35, 41, 42, 43, 44] }

    tileset_tex { _tileset_tex }
    tileset_tex=(s) { _tileset_tex = s }
    tile_width { _tile_width }
    tile_width=(s) { _tile_width = s }
    tile_height { _tile_height }
    tile_height=(s) { _tile_height = s }
    island_radius_max { _island_radius_max }
    island_radius_max=(s) { _island_radius_max = s }
    island_radius_min { _island_radius_min }
    island_radius_min=(s) { _island_radius_min = s }
    minimum_distance { _minimum_distance }
    minimum_distance=(s) { _minimum_distance = s }

    construct new() {
        _tileset_tex = null
        _tile_width = 0
        _tile_height = 0
        _island_radius_max = 0
        _island_radius_min = 0
        _minimum_distance = 0
        _start_tile = []
        _end_tile = []
    }

    towards_zero(val) {
        return val < 0 ? val + 1 : val - 1
    }

    sign(val) {
        return val < 0 ? -1 : (val > 0 ? 1 : 0)
    }

    get_tile(tiles, rng) {
        return tiles[rng.int(tiles.count)]
    }

    is_ground(tile) {
        for (current_tile in Generator.GROUND_TILES) {
            if (current_tile == tile) {
                return true
            }
        }
        return false
    }

    player_start_x { _start_tile[0] * _tile_width }
    player_start_y { _start_tile[1] * _tile_height }

    ending_spot_x { _end_tile[0] * _tile_width }
    ending_spot_y { _end_tile[1] * _tile_height }

    // Call this to make a level
    generate_level(width, height, island_count, seed) {
        var rng = Random.new(seed)
        var tileset_array_1 = []
        var tileset_array_2 = []
        var tileset_array_3 = []
        for (y in 0..(height - 1)) {
            var inner_tileset_1 = []
            var inner_tileset_2 = []
            var inner_tileset_3 = []
            for (x in 0..(width - 1)) {
                inner_tileset_1.add(0)
                inner_tileset_2.add(0)
                inner_tileset_3.add(0)
            }
            tileset_array_1.add(inner_tileset_1)
            tileset_array_2.add(inner_tileset_2)
            tileset_array_3.add(inner_tileset_3)
        }
        var tileset_ground = Tileset.new(tileset_array_1, tileset_tex, tile_width, tile_height)
        var tileset_background = Tileset.new(tileset_array_2, tileset_tex, tile_width, tile_height)
        var tileset_foreground = Tileset.new(tileset_array_2, tileset_tex, tile_width, tile_height)

        // Pick a few spots for the islands
        var island_spots = []
        for (i in 0..(island_count - 1)) {
            var intersects = true
            var spot = []
            var attempts = 0
            while (intersects && attempts < 10) {
                intersects = false
                spot = [rng.int(island_radius_max, width - island_radius_max), rng.int(island_radius_max, height - island_radius_max), rng.int(island_radius_min, island_radius_max)]
                if (i > 0) {
                    for (j in i - 1..0) {
                        if (Math.point_distance(spot[0], spot[1], island_spots[j][0], island_spots[j][1]) < minimum_distance) {
                            intersects = true
                        }
                    }
                }
                attempts = attempts + 1
            }
            island_spots.add(spot)
            tileset_ground[spot[0], spot[1]] = get_tile(Generator.GROUND_TILES, rng)
        }

        // Fill out the islands
        for (y in 0..height - 1) {
            for (x in 0..width - 1) {
                // Check each spot to see if this is close enough
                for (spot in island_spots) {
                    if (Math.point_distance(spot[0], spot[1], x, y) < spot[2]) {
                        tileset_ground[x, y] = get_tile(Generator.GROUND_TILES, rng)
                    }
                }
            }
        }

        // Connect the islands
        for (spot in 0..island_spots.count - 1) {
            var current = island_spots[spot]
            var next = island_spots[spot == (island_spots.count - 1) ? 0 : spot + 1]
            var x_displacement = next[0] - current[0]
            var y_displacement = next[1] - current[1]
            var x = current[0]
            var y = current[1]
            while (x_displacement != 0 || y_displacement != 0) {
                if (x_displacement != 0 && y_displacement != 0) {
                    if (rng.int(10) <= 4) {
                        x = x + sign(x_displacement)
                        x_displacement = towards_zero(x_displacement)
                    } else {
                        y = y + sign(y_displacement)
                        y_displacement = towards_zero(y_displacement)
                    }
                } else if (x_displacement != 0) {
                    x = x + sign(x_displacement)
                    x_displacement = towards_zero(x_displacement)
                } else {
                    y = y + sign(y_displacement)
                    y_displacement = towards_zero(y_displacement)
                }
                tileset_ground[x, y] = get_tile(Generator.GROUND_TILES, rng)
                tileset_ground[x, y - 1] = get_tile(Generator.GROUND_TILES, rng)
                tileset_ground[x - 1, y] = get_tile(Generator.GROUND_TILES, rng)
            }
        }

        // Add little wall/background effect
        for (y in 1..height - 1) {
            for (x in 0..width - 1) {
                // Drop-down walls
                if (is_ground(tileset_ground[x, y - 1]) && tileset_ground[x, y] == 0) {
                    tileset_background[x, y] = get_tile(Generator.DROP_TILES, rng)
                }

                // Small decoration tiles
                if (is_ground(tileset_ground[x, y]) && rng.int(10) == 2) {
                    tileset_foreground[x, y] = get_tile(Generator.DECORATION_TILES, rng)
                }
            }
        }

        _start_tile = rng.sample(island_spots)
        island_spots.remove(_start_tile)
        _end_tile = rng.sample(island_spots)

        return {"ground": tileset_ground, "background": tileset_background, "foreground": tileset_foreground}
    }
}