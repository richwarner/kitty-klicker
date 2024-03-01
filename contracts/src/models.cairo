use starknet::ContractAddress;

// struct for player score
#[derive(Model, Copy, Drop, Serde)]
struct Score {
    #[key]
    player_id: u8,
    value: u256
}

// struct for amount of points player gets per click
#[derive(Model, Copy, Drop, Serde)]
struct ClickPower {
    #[key]
    player_id: u8,
    value: u256
}

// struct to keep track of bought upgrades per player
#[derive(Model, Copy, Drop, Serde)]
struct Inventory {
    #[key]
    player_id: u8,
    DiamondPaw: u128,
    GoldenPaw: u128
}

// Constant definition for a game data key. This allows us to fetch this model using the key.
const GAME_DATA_KEY: felt252 = 'game';

// Structure representing a player's ID with a ContractAddress
#[derive(Model, Copy, Drop, Serde)]
struct PlayerID {
    #[key]
    player: ContractAddress,
    id: u8,
}

// Structure linking a player's ID to their ContractAddress
#[derive(Model, Copy, Drop, Serde)]
struct PlayerAddress {
    #[key]
    id: u8,
    player: ContractAddress,
}

// Structure for storing game data with a key, number of players, and available IDs
#[derive(Model, Copy, Drop, Serde)]
struct GameData {
    #[key]
    game: felt252, // Always 'game'
    number_of_players: u8,
    available_ids: u256, // Packed u8s?
}
