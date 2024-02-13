#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;
    use starknet::ContractAddress;
    use debug::PrintTrait;

    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // import model structs
    // the lowercase structs hashes generated by the compiler
    use emojiman::models::{
        position, player_at_position, rps_type, energy, player_id, player_address, click_power,
        score, upgrade, Position, RPSType, Energy, Direction, Vec2, PlayerAtPosition, PlayerID,
        PlayerAddress, ClickPower, Score, UpgradeItem, Upgrade
    };

    // import actions dojo contract
    use emojiman::actions::actions;

    // import interface
    use emojiman::interface::{IActions, IActionsDispatcher, IActionsDispatcherTrait};

    // import config
    use emojiman::config::{INITIAL_ENERGY, RENEWED_ENERGY, MOVE_ENERGY_COST};

    // NOTE: Spawn world helper function
    // 1. deploys world contract
    // 2. deploys actions contract
    // 3. sets models within world
    // 4. returns caller, world dispatcher and actions dispatcher for use in testing!
    fn spawn_world() -> (ContractAddress, IWorldDispatcher, IActionsDispatcher) {
        let caller = starknet::contract_address_const::<'jon'>();

        // This sets caller for current function, but not passed to called contract functions
        starknet::testing::set_caller_address(caller);

        // This sets caller for called contract functions.
        starknet::testing::set_contract_address(caller);

        // NOTE: Models
        // we create an array here to pass to spawn_test_world. This 'sets' the models within the world.
        let mut models = array![
            player_at_position::TEST_CLASS_HASH,
            position::TEST_CLASS_HASH,
            energy::TEST_CLASS_HASH,
            rps_type::TEST_CLASS_HASH,
            player_id::TEST_CLASS_HASH,
            player_address::TEST_CLASS_HASH,
            click_power::TEST_CLASS_HASH,
            score::TEST_CLASS_HASH,
            upgrade::TEST_CLASS_HASH
        ];

        // deploy world with models
        let world = spawn_test_world(models);

        // deploy systems contract
        let contract_address = world
            .deploy_contract('actions', actions::TEST_CLASS_HASH.try_into().unwrap());

        // returns
        (caller, world, IActionsDispatcher { contract_address })
    }

    #[test]
    #[available_gas(30000000)]
    fn spawn_test() {
        let (caller, world, actions_) = spawn_world();

        actions_.spawn();

        // Get player ID
        let player_id = get!(world, caller, (PlayerID)).id;
        assert(1 == player_id, 'incorrect id');

        //Get player ClickPower
        let click_power = get!(world, player_id, (ClickPower)).value;
        assert(click_power == 10, 'incorrect click_power');

        // Get player Score 
        let score = get!(world, player_id, (Score)).value;
        assert(score == 0, 'score should be 0');
    }

    #[test]
    #[available_gas(30000000)]
    fn click_test() {
        let (caller, world, actions_) = spawn_world();

        actions_.spawn();
        // Get player ID
        let player_id = get!(world, caller, (PlayerID)).id;
        assert(1 == player_id, 'incorrect id');
        
        actions_.click_kitty();

        // Get player score after 1 click
        let score = get!(world, player_id, (Score)).value;
        assert(score == 10, 'Score should be 10');
        
        actions_.click_kitty();

        // Get player score after 2 clicks
        let score = get!(world, player_id, (Score)).value;
        assert(score == 20, 'Score should be 20');
    }

    #[test]
    #[available_gas(90000000)]
    fn buy_upgrade_test() {
        let (caller, world, actions_) = spawn_world();

        actions_.spawn();

        // Get player ID
        let player_id = get!(world, caller, (PlayerID)).id;
        assert(1 == player_id, 'incorrect id');
        
        // Click 5 times to get 50 score
        actions_.click_kitty();
        actions_.click_kitty();
        actions_.click_kitty();
        actions_.click_kitty();
        actions_.click_kitty();

        // buy Upgrade 
        actions_.buy_upgrade(UpgradeItem::GoldenPaw);

        // get new ClickPower 
        let click_power = get!(world, player_id, (ClickPower)).value;
        assert(click_power == 15, 'click power should be 15');

        // get new score
        let score = get!(world, player_id, (Score)).value;
        assert(score == 0, 'score should be 0');
    }


// #[test]
// #[available_gas(30000000)]
// fn moves_test() {
//     let (caller, world, actions_) = spawn_world();

//     actions_.spawn('r');

//     // Get player ID
//     let player_id = get!(world, caller, (PlayerID)).id;
//     assert(1 == player_id, 'incorrect id');

//     let (spawn_pos, spawn_energy) = get!(world, player_id, (Position, Energy));

//     actions_.move(Direction::Up);
//     // Get player from id
//     let (pos, energy) = get!(world, player_id, (Position, Energy));

//     // assert player moved and energy was deducted
//     assert(energy.amt == spawn_energy.amt - MOVE_ENERGY_COST, 'incorrect energy');
//     assert(spawn_pos.x == pos.x, 'incorrect position.x');
//     assert(spawn_pos.y - 1 == pos.y, 'incorrect position.y');
// }

// #[test]
// #[available_gas(30000000)]
// fn player_at_position_test() {
//     let (caller, world, actions_) = spawn_world();

//     actions_.spawn('r');

//     // Get player ID
//     let player_id = get!(world, caller, (PlayerID)).id;

//     // Get player position
//     let Position{x, y, id } = get!(world, player_id, Position);

//     // Player should be at position
//     assert(actions::player_at_position(world, x, y) == player_id, 'player should be at pos');

//     // Player moves
//     actions_.move(Direction::Up);

//     // Player shouldn't be at old position
//     assert(actions::player_at_position(world, x, y) == 0, 'player should not be at pos');

//     // Get new player position
//     let Position{x, y, id } = get!(world, player_id, Position);

//     // Player should be at new position
//     assert(actions::player_at_position(world, x, y) == player_id, 'player should be at pos');
// }

// NOTE: Internal function tests

}
