pub mod commands;
mod cli {
    pub mod reinstall;
}


use argh::FromArgs;
use commands::Commands;

/// A CLI Application made just for Eveeifyeve
#[derive(FromArgs)]
pub struct AppConfig {
    #[argh(subcommand)]
    _commands: commands::Commands,
}


const FORMULA_INSTALL: &[&str] = &["neovim", "tmux", "btop", "gh"];
const CASKS_INSTALL: &[&str] = &["raycast", "wezterm"]; 


fn main() {
    let app_config: AppConfig = argh::from_env();

    match app_config._commands {
        Commands::Reinstall(reinstall_arg) => {
        cli::reinstall::main(reinstall_arg.apps);
    },
        Commands::GitCheck(_) => {

        }
    }
}