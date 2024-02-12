use argh::FromArgs;

#[derive(FromArgs, PartialEq, Debug)]
#[argh(subcommand)]
pub enum Commands {
    GitCheck(GitCheck),
    Reinstall(Reinstall),
}



/// Checks if you have commited in a folder of projects.
#[derive(FromArgs, PartialEq, Debug)]
#[argh(subcommand, name = "git check_folders")]
pub struct GitCheck {
    #[argh(option, long = "path")]
    /// path for the git check
    path: Option<String>,
}



/// Reinstall apps.
#[derive(FromArgs, PartialEq, Debug)]
#[argh(subcommand, name = "reinstall")]
pub struct Reinstall {}
