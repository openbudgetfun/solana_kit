use anchor_lang::prelude::*;

declare_id!("Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS");

#[program]
pub mod anchor_compatibility {
    use super::*;

    pub fn initialize(
        ctx: Context<Initialize>,
        initial_value: u64,
        label: String,
    ) -> Result<()> {
        require!(label.len() <= 32, CompatibilityError::LabelTooLong);

        let counter = &mut ctx.accounts.counter;
        counter.authority = ctx.accounts.authority.key();
        counter.value = initial_value;
        counter.label = label.clone();

        emit!(CounterChanged {
            authority: counter.authority,
            previous_value: 0,
            value: initial_value,
            label,
        });
        Ok(())
    }

    pub fn increment(ctx: Context<Increment>, amount: u64) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        let previous_value = counter.value;
        counter.value = previous_value
            .checked_add(amount)
            .ok_or(CompatibilityError::CounterOverflow)?;

        emit!(CounterChanged {
            authority: counter.authority,
            previous_value,
            value: counter.value,
            label: counter.label.clone(),
        });
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = authority, space = 8 + Counter::INIT_SPACE)]
    pub counter: Account<'info, Counter>,
    #[account(mut)]
    pub authority: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Increment<'info> {
    #[account(mut, has_one = authority)]
    pub counter: Account<'info, Counter>,
    pub authority: Signer<'info>,
}

#[account]
#[derive(InitSpace)]
pub struct Counter {
    pub authority: Pubkey,
    pub value: u64,
    #[max_len(32)]
    pub label: String,
}

#[event]
pub struct CounterChanged {
    pub authority: Pubkey,
    pub previous_value: u64,
    pub value: u64,
    pub label: String,
}

#[error_code]
pub enum CompatibilityError {
    #[msg("The counter would overflow a u64")]
    CounterOverflow,
    #[msg("The counter label must be at most 32 bytes")]
    LabelTooLong,
}
