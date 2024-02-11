use clap:: {
    Args, 
    Parser,
    Subcommand
};


/// Search for a pattern in a file and display the lines that contain it.
#[derive(Parser)]
pub struct Test {
    /// The pattern to look for
    pattern: String,
}

