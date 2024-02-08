// ---------------------------------------------------------------------
// This file contains the interface of the contract.
// ---------------------------------------------------------------------
use emojiman::utils::{UpgradeItem};

#[starknet::interface]
trait IActions<TContractState> {
    fn spawn(self: @TContractState);
    fn click_kitty(self: @TContractState, target_id: u8);
    fn buy_upgrade(self: @TContractState, selected_upgrade: UpgradeItem);
    fn cleanup(self: @TContractState);
}
