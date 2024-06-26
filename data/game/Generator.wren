import "BlueSlime" for BlueSlime
import "Ranger" for Ranger
import "Constants" for Constants
import "random" for Random
import "NPC" for NPC
import "Spikes" for Spikes
import "Character" for Character

// Generates a random sky level and returns the grid
class Generator {
    static GROUND_TILE { 1 }
    static DROP_TILE { 11 }
    static DECORATION_TILES { [31, 32, 33, 34, 35, 41, 42, 43, 44, 45] }

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
        return tile == 1
    }

    // Returns
    get_entity_locations(locations, x, y, rng) {
        if (Math.point_distance(_start_tile[0], _start_tile[1], x, y) > Constants.SPAWN_GRACE_RANGE) {
            locations.add([x * _tile_width + (_tile_width / 2), y * _tile_height + (_tile_height / 2)])
        }
        return locations
    }

    // Place enemies
    place_enemies(level, count, rng, locations) {
        for (i in 1..count) {
            var location = rng.sample(locations)
            locations.remove(location)
            var e = level.add_entity(rng.sample([Ranger, BlueSlime]))
            e.x = location[0]
            e.y = location[1]
        }
    }

    // Places props
    place_props(level, count, rng, locations) {
        for (i in 1..count) {
            var location = rng.sample(locations)
            locations.remove(location)
            level.add_prop(location[0], location[1])
        }
    }

    place_traps(level, count, rng, locations) {
        for (i in 1..count) {
            var location = rng.sample(locations)
            locations.remove(location)
            var spikes = level.add_entity(Spikes)
            spikes.x = location[0]
            spikes.y = location[1]
        }
    }

    generate_collision_map(ground_tileset) {
        // Generate collision tileset
        var arr = []
        for (i in 0..ground_tileset.tiles_tall - 1) {
            var inner = []
            for (j in 0..ground_tileset.tiles_wide - 1) {
                if (ground_tileset[j, i] == 0) {
                    inner.add(160)
                } else {
                    inner.add(0)
                }
            }
            arr.add(inner)
        }
        return Tileset.new(arr, Assets.tex_tiles, ground_tileset.tile_width, ground_tileset.tile_height)
    }

    autotile(tileset_ground, tileset_background, locations, rng) {
        for (y in 1..tileset_background.tiles_tall - 2) {
            for (x in 1..tileset_background.tiles_wide - 2) {
                if (tileset_ground[x, y] != 0) {
                    var above = tileset_ground[x, y - 1] != 0
                    var below = tileset_ground[x, y + 1] != 0
                    var left = tileset_ground[x - 1, y] != 0
                    var right = tileset_ground[x + 1, y] != 0
                    var drop_right = tileset_ground[x + 1, y] != Generator.DROP_TILE
                    var drop_left = tileset_ground[x - 1, y] != Generator.DROP_TILE
                    
                    // Autotile the ground
                    if (!below && !above && !left && !right) {
                        tileset_ground[x, y] = 17
                    } else if (!below && !above && left && right) {
                        tileset_ground[x, y] = 10
                    } else if (below && above && !left && !right) {
                        tileset_ground[x, y] = 4
                    } else if (below && !above && left && !right) {
                        tileset_ground[x, y] = 5
                    } else if (below && !above && !left && right) {
                        tileset_ground[x, y] = 7
                    } else if (!below && above && !left && right) {
                        tileset_ground[x, y] = 8
                    } else if (!below && above && left && !right) {
                        tileset_ground[x, y] = 9
                    } else if (!below && above && left && right) {
                        tileset_ground[x, y] = 1
                    } else if (below && above && !left && right) {
                        tileset_ground[x, y] = 2
                    } else if (below && above && left && !right) {
                        tileset_ground[x, y] = 3
                    } else if (below && !above && left && right) {
                        tileset_ground[x, y] = 6
                    } else if (below && above && left && right) {
                        tileset_ground[x, y] = 16
                    }

                    get_entity_locations(locations, x, y, rng)
                } else if (tileset_background[x, y] != 0) {
                    var above = tileset_ground[x, y - 1] != 0
                    var below = tileset_ground[x, y + 1] != 0
                    var left = tileset_ground[x - 1, y] != 0
                    var right = tileset_ground[x + 1, y] != 0
                    var drop_right = tileset_background[x + 1, y] != 0
                    var drop_left = tileset_background[x - 1, y] != 0

                    // Autotile the drop tiles
                    if (!below && ((drop_right && drop_left) || (left && right) || (left && drop_right) || (drop_left && right))) {
                        tileset_background[x, y] = 12
                    } else if (!below && (drop_right || right) && !drop_left && !left) {
                        tileset_background[x, y] = 13
                    } else if (!below && !drop_right && !right && (drop_left || left)) {
                        tileset_background[x, y] = 14
                    } else if (!below && !drop_right && !drop_left && !left && !right) {
                        tileset_background[x, y] = 15
                    }
                }
            }
        }
    }

    add_decoration(tileset_ground, tileset_background, tileset_foreground, rng) {
        for (y in 1..tileset_background.tiles_tall - 1) {
            for (x in 1..tileset_background.tiles_wide - 1) {
                // Drop-down walls
                if (is_ground(tileset_ground[x, y - 1]) && tileset_ground[x, y] == 0) {
                    tileset_background[x, y] = Generator.DROP_TILE
                }

                // Small decoration tiles
                if (is_ground(tileset_ground[x, y]) && rng.int(10) == 2) {
                    tileset_foreground[x, y] = get_tile(Generator.DECORATION_TILES, rng)
                }
            }
        }
    }

    give_knickknack(level, rng) {
        var characters = level.get_entities(Character)
        var char = rng.sample(characters)
        while (char is NPC) {
            char = rng.sample(characters)
        }
        char.give_knickknack()
    }

    place_npcs(level, locations, rng) {
        var location = rng.sample(locations)
        locations.remove(location)
        var npc = level.add_entity(NPC)
        npc.set_start_location(location[0], location[1])
    }

    player_start_x { _start_tile[0] * _tile_width }
    player_start_y { _start_tile[1] * _tile_height }

    ending_spot_x { _end_tile[0] * _tile_width }
    ending_spot_y { _end_tile[1] * _tile_height }

    // Call this to make a level
    generate_level(width, height, island_count, level) {
        var rng = level.rng
        var locations = []
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
            tileset_ground[spot[0], spot[1]] = Generator.GROUND_TILE
        }

        // Fill out the islands
        for (y in 0..height - 1) {
            for (x in 0..width - 1) {
                // Check each spot to see if this is close enough
                for (spot in island_spots) {
                    if (Math.point_distance(spot[0], spot[1], x, y) < spot[2]) {
                        tileset_ground[x, y] = Generator.GROUND_TILE
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
                tileset_ground[x, y] = Generator.GROUND_TILE
                tileset_ground[x, y - 1] = Generator.GROUND_TILE
                tileset_ground[x - 1, y] = Generator.GROUND_TILE
            }
        }

        // Generate collision tileset
        var collisions = generate_collision_map(tileset_ground)

        // Dropdown wall effect
        add_decoration(tileset_ground, tileset_background, tileset_foreground, rng)

        // Pick start and end tile
        _start_tile = rng.sample(island_spots)
        island_spots.remove(_start_tile)
        _end_tile = rng.sample(island_spots)

        // Autotile pass
        autotile(tileset_ground, tileset_background, locations, rng)

        // Place entities and such
        place_enemies(level, rng.int(15, 20), rng, locations)
        place_npcs(level, locations, rng)
        place_props(level, rng.int(Constants.MIN_PROPS, Constants.MAX_PROPS + 1), rng, locations)
        place_traps(level, rng.int(Constants.MIN_TRAPS, Constants.MAX_TRAPS + 1), rng, locations)
        give_knickknack(level, rng)

        return {"collisions": collisions, "ground": tileset_ground, "background": tileset_background, "foreground": tileset_foreground}
    }
}