#[cfg(test)]
use std::path::PathBuf;
#[cfg(test)]
use super::cli;

#[test]
fn test_statusr_subcommand() {
    let app = cli();
    let matches = app.get_matches_from(vec!["eve", "statusr", "/path/to/directory"]);

    assert_eq!(matches.subcommand_name(), Some("statusr"));
    assert_eq!(matches.subcommand_matches("statusr").unwrap().get_one::<PathBuf>("PATH"), Some(PathBuf::from("/path/to/directory")).as_ref());
}

#[test]
fn test_reinstall_subcommand() {
    let app = cli();
    let matches = app.get_matches_from(vec!["eve", "reinstall"]);

    assert_eq!(matches.subcommand_name(), Some("reinstall"));
}