import "BlueSlime" for BlueSlime
import "Ranger" for Ranger
import "Wizard" for Wizard
import "Fighter" for Fighter
import "Rogue" for Rogue
import "Hunter" for Hunter
import "Alien" for Alien
import "Constants" for Constants
import "random" for Random
import "NPC" for NPC
import "Traps" for Spikes, FastSpikes, Teleporter, BombPlant
import "Character" for Character
import "Save" for Save

class Structures {
    construct new(foreground, collisions, width, height, minimum_size) {
        _foreground = foreground
        _collisions = collisions
        _width = width
        _height = height
        _minimum_size = minimum_size
    }
    foreground { _foreground }
    collisions { _collisions }
    width { _width }
    height { _height }
    minimum_size { _minimum_size }

    static STRUCTURE_HOUSE_1 {
        var foreground = [
            [0, 58, 59, 60],
            [0, 68, 69, 70],
            [77, 78, 79, 80],
            [87, 88, 89, 90],
            [97, 98, 99, 100]
        ]

        var collisions = [
            [0, 58, 59, 60],
            [0, 68, 69, 70],
            [0, 78, 79, 80],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        return Structures.new(foreground, collisions, 4, 5, 4)
    }
    
    static STRUCTURE_HOUSE_2 {
        var foreground = [
            [101, 102, 103, 104],
            [111, 112, 113, 114],
            [121, 122, 123, 124],
            [131, 132, 133, 134],
        ]

        var collisions = [
            [0, 0, 0, 0],
            [0, 112, 113, 0],
            [0, 122, 123, 0],
            [0, 0, 0, 0],
        ]
        return Structures.new(foreground, collisions, 4, 4, 4)
    }

    static STRUCTURE_HOUSE_3 {
        var foreground = [
            [107, 108, 0, 0],
            [117, 118, 119, 120],
            [0, 128, 129, 130],
            [0, 138, 139, 140],
            [0, 148, 149, 150],
        ]

        var collisions = [
            [107, 108, 0, 0],
            [117, 118, 119, 120],
            [0, 128, 129, 130],
            [0, 138, 139, 140],
            [0, 0, 0, 0],
        ]
        return Structures.new(foreground, collisions, 4, 5, 5)
    }

    static get_random_structure(rng) {
        var list = [Structures.STRUCTURE_HOUSE_1, Structures.STRUCTURE_HOUSE_1, Structures.STRUCTURE_HOUSE_2, Structures.STRUCTURE_HOUSE_3, Structures.STRUCTURE_HOUSE_3]
        return rng.sample(list)
    }

    static STRUCTURE_ENVIRONMENT_BLOCK {
        var foreground = [
            [53]
        ]

        var collisions = [
            [53]
        ]
        return Structures.new(foreground, collisions, 1, 1, 1)
    }

    static STRUCTURE_ENVIRONMENT_PROP_1 {
        var foreground = [
            [81],
            [91],
        ]

        var collisions = [
            [81],
            [91],
        ]
        return Structures.new(foreground, collisions, 1, 2, 1)
    }

    static STRUCTURE_ENVIRONMENT_PROP_2 {
        var foreground = [
            [82],
            [92],
        ]

        var collisions = [
            [82],
            [92],
        ]
        return Structures.new(foreground, collisions, 1, 2, 1)
    }

    static STRUCTURE_ENVIRONMENT_PROP_3 {
        var foreground = [
            [83],
            [93],
        ]

        var collisions = [
            [83],
            [93],
        ]
        return Structures.new(foreground, collisions, 1, 2, 1)
    }

    static STRUCTURE_ENVIRONMENT_HORIZONTAL_2 {
        var foreground = [
            [65, 66]
        ]

        var collisions = [
            [65, 66]
        ]
        return Structures.new(foreground, collisions, 2, 1, 1)
    }

    static STRUCTURE_ENVIRONMENT_VERTICAL_2 {
        var foreground = [
            [57],
            [67]
        ]

        var collisions = [
            [57],
            [67]
        ]
        return Structures.new(foreground, collisions, 1, 2, 1)
    }

    static STRUCTURE_ENVIRONMENT_L_LEFT {
        var foreground = [
            [54, 55, 56],
            [64, 0, 0]
        ]

        var collisions = [
            [54, 55, 56],
            [64, 0, 0]
        ]
        return Structures.new(foreground, collisions, 3, 2, 1)
    }
    
    static STRUCTURE_ENVIRONMENT_L_RIGHT {
        var foreground = [
            [74, 75, 76],
            [0, 0, 86]
        ]

        var collisions = [
            [74, 75, 76],
            [0, 0, 86]
        ]
        return Structures.new(foreground, collisions, 3, 2, 1)
    }
    
    static STRUCTURE_ENVIRONMENT_CROSS {
        var foreground = [
            [0, 85, 0],
            [94, 95, 96],
            [0, 105, 0]
        ]

        var collisions = [
            [0, 85, 0],
            [94, 95, 96],
            [0, 105, 0]
        ]
        return Structures.new(foreground, collisions, 3, 3, 1)
    }
}

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
        var enemy_list_by_stage = []
        if (!Save.oops_all_wizards) {
            enemy_list_by_stage = [
                [BlueSlime],
                [BlueSlime, BlueSlime, BlueSlime, Ranger, Ranger],
                [Ranger, Ranger, Ranger, Fighter, Fighter, BlueSlime],
                [Fighter, Fighter, Wizard, Wizard, Ranger, Rogue],
                [Fighter, Fighter, Rogue, Rogue, Wizard, Wizard, Hunter]
            ]
        } else {
            enemy_list_by_stage = [
                [Wizard],
                [Wizard],
                [Wizard],
                [Wizard],
                [Wizard]
            ]
        }

        for (i in 1..count) {
            var location = get_location(locations, rng)
            var e = level.add_entity(rng.sample(enemy_list_by_stage[Save.stage - 1]))
            e.x = location[0]
            e.y = location[1]
        }
    }

    // Places props
    place_props(level, count, rng, locations) {
        for (i in 1..count) {
            var location = get_location(locations, rng)
            level.add_prop(location[0], location[1])
        }
    }

    place_traps(level, count, rng, locations) {
        var trap_list_by_stage = [
            [Spikes],
            [Spikes],
            [BombPlant, Spikes],
            [FastSpikes, Teleporter],
            [BombPlant, FastSpikes, Teleporter],
            []
        ]

        if (trap_list_by_stage[Save.stage - 1].count == 0) {
            return
        }

        for (i in 1..count) {
            var location = get_location(locations, rng)
            var spikes = level.add_entity(rng.sample(trap_list_by_stage[Save.stage - 1]))
            spikes.x = location[0]
            spikes.y = location[1]
        }
    }

    get_location(locations, rng) {
        var spot = rng.sample(locations)
        while (spot[0] < 100 || spot[1] < 100) {
            spot = rng.sample(locations)
        }
        locations.remove(spot)
        return spot
    }

    generate_collision_map(ground_tileset, locations, rng) {
        // Generate collision tileset
        var arr = []
        for (i in 0..ground_tileset.tiles_tall - 1) {
            var inner = []
            for (j in 0..ground_tileset.tiles_wide - 1) {
                if (ground_tileset[j, i] == 0) {
                    inner.add(160)
                } else {
                    inner.add(0)
                    get_entity_locations(locations, j, i, rng)
                }
            }
            arr.add(inner)
        }
        return Tileset.new(arr, Save.stage <= 3 ? Assets.tex_tiles : Assets.tex_tilesmoon, ground_tileset.tile_width, ground_tileset.tile_height)
    }

    autotile(tileset_ground, tileset_background, locations, collisions, rng) {
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
                if (is_ground(tileset_ground[x, y]) && rng.int(5) == 2) {
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
        characters.remove(char)
        char.give_knickknack()

        char = rng.sample(characters)
        while (char is NPC) {
            char = rng.sample(characters)
        }
        characters.remove(char)
        char.give_key()

        // Give chests
        var chests = rng.int(Constants.LEVEL_RANDOM_CHEST_MIN[Save.stage - 1], Constants.LEVEL_RANDOM_CHEST_MAX[Save.stage - 1] + 1)
        while (chests > 0) {
            char = rng.sample(characters)
            characters.remove(char)
            char.give_chest()
            chests = chests - 1
        }
    }

    place_npcs(level, locations, rng) {
        var location = get_location(locations, rng)
        var npc = level.add_entity(NPC)
        npc.set_start_location(location[0], location[1])
    }

    is_minimum_distance(structures, new_structure, spot) {
        for (structure in structures) {
            if (Math.point_distance(structure[0][0], structure[0][1], spot[0], spot[1]) < structure[1] + new_structure.minimum_size) {
                return false
            }
        }
        var pass = Math.point_distance(spot[0], spot[1], _start_tile[0], _start_tile[1]) > new_structure.minimum_size + 1 && Math.point_distance(spot[0], spot[1], _end_tile[0], _end_tile[1]) > new_structure.minimum_size + 1
        return pass
    }

    // x/y should be a tile coordinate
    remove_location(locations, x, y) {
        // Remove location from locations list
        for (l in locations) {
            var place = [((x) * tile_width) + (tile_width / 2), ((y) * tile_height) + (tile_height / 2)]
            if (l[0] == place[0] && l[1] == place[1]) {
                locations.remove(l)
                break
            }
        }
    }

    place_structures(level, foreground, collisions, island_spots, rng, locations) {
        var count = rng.int(Constants.MIN_STRUCTURES, Constants.MAX_STRUCTURES + 1)
        var structure_spots = []
        
        // Pick x random spots to put the structures
        for (i in 1..count) {
            // Attempt to find a spot for a structure
            var attempts = 0
            var spot = rng.sample(island_spots)
            var structure = Structures.get_random_structure(rng)
            while (attempts < 10 && structure.minimum_size > spot[2] && is_minimum_distance(structure_spots, structure, spot)) {
                attempts = attempts + 1
                spot = rng.sample(island_spots)
                structure = Structures.get_random_structure(rng)
            }
            
            // Make sure the island is big enough
            if (structure.minimum_size <= spot[2] && is_minimum_distance(structure_spots, structure, spot)) {
                // Place the structure
                structure_spots.add([spot, structure.minimum_size])
                island_spots.remove(spot)
                var start_x = spot[0] - (structure.width / 2).floor
                var start_y = spot[1] - (structure.height / 2).floor
                var tile_width = foreground.tile_width
                var tile_height = foreground.tile_height
                for (y in 0..structure.height - 1) {
                    for (x in 0..structure.width - 1) {
                        foreground[x + start_x, y + start_y] = structure.foreground[y][x]
                        collisions[x + start_x, y + start_y] = structure.collisions[y][x]

                        remove_location(locations, x + start_x, y + start_y)
                    }
                }
            }
        }
    }

    place_environment_structures(level, foreground, collisions, island_spots, rng, locations) {
        var block = Structures.STRUCTURE_ENVIRONMENT_BLOCK
        var horizontal2 = Structures.STRUCTURE_ENVIRONMENT_HORIZONTAL_2
        var vertical2 = Structures.STRUCTURE_ENVIRONMENT_VERTICAL_2
        var l_left = Structures.STRUCTURE_ENVIRONMENT_L_LEFT
        var l_right = Structures.STRUCTURE_ENVIRONMENT_L_RIGHT
        var cross = Structures.STRUCTURE_ENVIRONMENT_CROSS
        var prop1 = Structures.STRUCTURE_ENVIRONMENT_PROP_1
        var prop2 = Structures.STRUCTURE_ENVIRONMENT_PROP_2
        var prop3 = Structures.STRUCTURE_ENVIRONMENT_PROP_3
        var structures = [block, horizontal2, vertical2, l_left, l_right, cross, prop1, prop1, prop2, prop2, prop3]

        var count = rng.int(Constants.LEVEL_ENVIRONMENT_STRUCTURES_MIN[Save.stage - 1], Constants.LEVEL_ENVIRONMENT_STRUCTURES_MAX[Save.stage - 1] + 1)

        for (i in 1..count) {
            var attempts = 10
            var valid_location = null
            var chosen_structure = rng.sample(structures)
            
            // Attempt to find a place for this structure in locations
            while (attempts > 0 && valid_location == null) {
                attempts = attempts - 1
                var loc = rng.sample(locations)
                loc[0] = ((loc[0] - (0.5 * collisions.tile_width)) / collisions.tile_width).round
                loc[1] = ((loc[1] - (0.5 * collisions.tile_height)) / collisions.tile_height).round
                var collision = false

                // Make sure there is nothing on the collision layer here
                for (y in loc[1] - 1..loc[1] + chosen_structure.height) {
                    for (x in loc[0] - 1..loc[0] + chosen_structure.width) {
                        if (collisions[x, y] != 0) {
                            collision = true
                            break
                        }
                    }
                    if (collision) {
                        break
                    }
                }

                /*
                    [Runtime Error] Subscript must be an integer.
                    [lib/Util line 282] in [_,_]
                    [Generator line 514] in place_environment_structures(_,_,_,_,_,_)
                    [Generator line 663] in generate_level(_,_,_,_)
                    [Game line 353] in create()
                    [Runtime Error] Null does not implement 'width=(_)'.
                    [Game line 439] in pre_frame()
                */

                if (!collision) {
                    valid_location = loc
                }
            }

            // If we have a valid spot
            if (valid_location != null) {
                for (y in valid_location[1]..valid_location[1] + chosen_structure.height - 1) {
                    for (x in valid_location[0]..valid_location[0] + chosen_structure.width - 1) {
                        collisions[x, y] = chosen_structure.collisions[y - valid_location[1]][x - valid_location[0]]
                        foreground[x, y] = chosen_structure.foreground[y - valid_location[1]][x - valid_location[0]]
                        remove_location(locations, x, y)
                    }
                }
            }
        }
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

        // Pick start island
        _start_tile = rng.sample(island_spots)
        island_spots.remove(_start_tile)

        // End island shouldnt be near start
        var farthest = island_spots[0]
        for (spot in island_spots) {
            if (Math.point_distance(farthest[0], farthest[1], _start_tile[0], _start_tile[1]) < Math.point_distance(spot[0], spot[1], _start_tile[0], _start_tile[1])) {
                farthest = spot
            }
        }

        // Generate collision tileset
        var collisions = generate_collision_map(tileset_ground, locations, rng)

        // Dropdown wall effect
        add_decoration(tileset_ground, tileset_background, tileset_foreground, rng)

        _end_tile = farthest
        island_spots.remove(_end_tile)

        // Autotile pass
        autotile(tileset_ground, tileset_background, locations, collisions, rng)
        remove_location(locations, _end_tile[0], _end_tile[1])
        remove_location(locations, _start_tile[0], _start_tile[1])

        // Remove locations to close to the edge
        var new_locs = []
        for (loc in locations) {
            if (loc[0] > 200 && loc[1] > 200) {
                new_locs.add(loc)
            }
        }
        //locations = new_locs
        //System.print(locations)
        //System.print("\n\n")

        // Place entities and such
        place_structures(level, tileset_foreground, collisions, island_spots, rng, locations)
        place_environment_structures(level, tileset_foreground, collisions, island_spots, rng, locations)
        place_enemies(level, rng.int(Constants.LEVEL_ENEMY_MIN[Save.stage - 1], Constants.LEVEL_ENEMY_MAX[Save.stage - 1] + 1), rng, locations)
        place_npcs(level, locations, rng)
        place_props(level, rng.int(Constants.MIN_PROPS, Constants.MAX_PROPS + 1), rng, locations)
        place_traps(level, rng.int(Constants.LEVEL_TRAP_MIN[Save.stage - 1], Constants.LEVEL_TRAP_MAX[Save.stage - 1] + 1), rng, locations)
        give_knickknack(level, rng)

        // Place start and end ladder
        tileset_foreground[_start_tile[0], _start_tile[1]] = 71
        tileset_foreground[_end_tile[0], _end_tile[1]] = 72
        tileset_foreground[_end_tile[0], _end_tile[1] - 1] = 62

        return {"collisions": collisions, "ground": tileset_ground, "background": tileset_background, "foreground": tileset_foreground}
    }
}