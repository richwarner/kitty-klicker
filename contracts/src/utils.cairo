use emojiman::models::{Position, Direction, UpgradeItem, Upgrade};

fn next_position(mut position: Position, direction: Direction) -> Position {
    match direction {
        Direction::None(()) => { return position; },
        Direction::Left(()) => { position.x -= 1; },
        Direction::Right(()) => { position.x += 1; },
        Direction::Up(()) => { position.y -= 1; },
        Direction::Down(()) => { position.y += 1; },
    };

    position
}

fn get_upgrade_from_catalogue(selected_upgrade: UpgradeItem) -> Upgrade {
    match selected_upgrade {
        UpgradeItem::GoldenPaw => Upgrade { name: 'Golden Paw', cp_increase: 5, cost: 50},
        UpgradeItem::DiamondPaw => Upgrade { name: 'Diamaond Paw', cp_increase: 10, cost: 100}
    }
}