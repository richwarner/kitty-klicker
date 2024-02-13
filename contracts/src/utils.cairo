// Declaration of an enum named 'UpgradeItem' with two upgrade variants
#[derive(Serde, Copy, Drop, Introspect)]
enum UpgradeItem {
    GoldenPaw,
    DiamondPaw,
}

// implementation of into trait for UpgradeItem
impl UpgradeItemIntoFelt252 of Into<UpgradeItem, felt252> {
    fn into(self: UpgradeItem) -> felt252 {
        match self {
            UpgradeItem::GoldenPaw(()) => 0,
            UpgradeItem::DiamondPaw(()) => 1
        }
    }
}

// struct for Upgrade details
#[derive(Copy, Drop, Serde)]
struct Upgrade {
    name: felt252,
    cp_increase: u256,
    cost: u256
}

fn get_upgrade_from_catalogue(selected_upgrade: UpgradeItem) -> Upgrade {
    match selected_upgrade {
        UpgradeItem::GoldenPaw => Upgrade { name: 'Golden Paw', cp_increase: 5, cost: 50},
        UpgradeItem::DiamondPaw => Upgrade { name: 'Diamaond Paw', cp_increase: 10, cost: 100}
    }
}