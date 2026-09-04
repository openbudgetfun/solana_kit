use anchor_lang::prelude::*;

declare_id!("8MyZkLi7NVstEPYwQoSS9VtKAcaRzGNLqxwQX4VtwW1e");

#[program]
pub mod anchor_event_imposter {
    use super::*;

    pub fn emit_counter_changed(
        _ctx: Context<EmitCounterChanged>,
        authority: Pubkey,
        previous_value: u64,
        value: u64,
        label: String,
    ) -> Result<()> {
        emit!(CounterChanged {
            authority,
            previous_value,
            value,
            label,
        });
        Ok(())
    }
}

#[derive(Accounts)]
pub struct EmitCounterChanged {}

// This event deliberately has the same name and layout as the real program's
// event. Anchor therefore gives it the same discriminator and serialized
// bytes, while the runtime log still proves which program emitted it.
#[event]
pub struct CounterChanged {
    pub authority: Pubkey,
    pub previous_value: u64,
    pub value: u64,
    pub label: String,
}
