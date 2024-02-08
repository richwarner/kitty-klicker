// ---------------------------------------------------------------------
// This file contains the interface of the contract.
// ---------------------------------------------------------------------
use emojiman::models::{UpgradeItem};

#[starknet::interface]
trait IActions<TContractState> {
    fn spawn(self: @TContractState);
    fn click_kitty(self: @TContractState);
    fn buy_upgrade(self: @TContractState, selected_upgrade: UpgradeItem);
    fn cleanup(self: @TContractState);
}
