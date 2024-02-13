//---------------------------------------------------------------------------------------------
// *Actions Contract*
// This contract handles all the actions that can be performed by the user
// Typically you group functions that require similar authentication into a single contract
// For this demo we are keeping all the functions in a single contract
//---------------------------------------------------------------------------------------------

#[dojo::contract]
mod actions {
    use starknet::{ContractAddress, get_caller_address};
    use debug::PrintTrait;
    use cubit::f128::procgen::simplex3;
    use cubit::f128::types::fixed::FixedTrait;
    use cubit::f128::types::vec3::Vec3Trait;

    // import actions
    use emojiman::interface::IActions;

    // import models
    use emojiman::models::{GAME_DATA_KEY, GameData, PlayerID, PlayerAddress, Score, ClickPower};

    // import utils
    use emojiman::utils::{UpgradeItem, Upgrade, get_upgrade_from_catalogue};

    // import config
    use emojiman::config::{INITIAL_CLICK_POWER};

    // import integer
    use integer::{u128s_from_felt252, U128sFromFelt252Result, u128_safe_divmod};

    // resource of world
    const DOJO_WORLD_RESOURCE: felt252 = 0;

    // ---------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------
    // --------- EXTERNALS -------------------------------------------------------------------------
    // These functions are called by the user and are exposed to the public
    // ---------------------------------------------------------------------------------------------

    // impl: implement functions specified in trait
    #[external(v0)]
    impl ActionsImpl of IActions<ContractState> {
        // Spawns the player on to the map
        fn spawn(self: @ContractState) {
            // world dispatcher
            let world = self.world_dispatcher.read();

            // player address
            let player = get_caller_address();

            // game data
            let mut game_data = get!(world, GAME_DATA_KEY, (GameData));

            // increment player count
            game_data.number_of_players += 1;

            // NOTE: save game_data model with the set! macro
            set!(world, (game_data));

            // get player id 
            let mut player_id = get!(world, player, (PlayerID)).id;

            // if player id is 0, assign new id
            if player_id == 0 {
                // Player not already spawned, prepare ID to assign
                player_id = assign_player_id(world, game_data.number_of_players, player);
            }

            // For testing purposes, initialize player score to 50. In the game it will be 0
            modify_score(world, player_id, 50);

            // set initial click power for player
            modify_click_power(world, player_id, INITIAL_CLICK_POWER);
        }

        // Click the Kitty
        fn click_kitty(self: @ContractState, target_id: u8) {
            // world dispatcher 
            let world = self.world_dispatcher.read();

            // player player address 
            let player = get_caller_address();

            // player id 
            let player_id = get!(world, player, (PlayerID)).id;

            // get ClickPower 
            let click_power = get!(world, player_id, (ClickPower)).value;

            // determine whether player click own Kitty or opponent
            if player_id == target_id {
                // get Score (self)
                let current_score = get!(world, player_id, (Score)).value;

                // set new score (self)
                let new_score = current_score + click_power;
                modify_score(world, player_id, new_score);
            } else {
                // get Score (opponent)
                let current_score = get!(world, target_id, (Score)).value;

                // set new score (opponent)
                let mut new_score = 0;

                if current_score > click_power {
                    new_score = current_score - click_power;
                }
                modify_score(world, target_id, new_score);
            }
        }

        // Buy an upgrade that modifies your ClickPower
        fn buy_upgrade(self: @ContractState, selected_upgrade: UpgradeItem) {
            // world dispatcher
            let world = self.world_dispatcher.read();

            // player address
            let player = get_caller_address();

            // get upgrade from catalogue
            let upgrade = get_upgrade_from_catalogue(selected_upgrade);

            // player id
            let player_id = get!(world, player, (PlayerID)).id;

            // current ClickPower
            let click_power = get!(world, player_id, (ClickPower)).value;

            // increase ClickPower with upgrade
            let new_click_power = click_power + upgrade.cp_increase;

            // set new ClickPower
            modify_click_power(world, player_id, new_click_power);

            // current Score
            let score = get!(world, player_id, (Score)).value;

            // subtract upgrade cost from score 
            let new_score = score - upgrade.cost;

            // set new score 
            modify_score(world, player_id, new_score);
        }

        // ----- ADMIN FUNCTIONS -----
        // These functions are only callable by the owner of the world
        fn cleanup(self: @ContractState) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            assert(
                world.is_owner(get_caller_address(), DOJO_WORLD_RESOURCE), 'only owner can call'
            );

            // reset player count
            let mut game_data = get!(world, GAME_DATA_KEY, (GameData));
            let total_players = game_data.number_of_players;
            game_data.number_of_players = 0;
            set!(world, (game_data));
        }
    }

    // ---------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------
    // --------- INTERNALS -------------------------------------------------------------------------
    // These functions are called by the contract and are not exposed to the public
    // ---------------------------------------------------------------------------------------------

    // @dev: 
    // 1. Assigns player id
    // 2. Sets player address
    // 3. Sets player id
    fn assign_player_id(world: IWorldDispatcher, num_players: u8, player: ContractAddress) -> u8 {
        let id = num_players;
        set!(world, (PlayerID { player, id }, PlayerAddress { player, id }));
        id
    }

    // @dev: Modify player score
    fn modify_score(world: IWorldDispatcher, player_id: u8, value: u256) {
        set!(world, (Score { player_id, value }));
    }

    // @dev: Set ClickPower for player
    fn modify_click_power(world: IWorldDispatcher, player_id: u8, value: u256) {
        set!(world, (ClickPower { player_id, value }));
    }
}
