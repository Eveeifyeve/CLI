use clap::Args;
use rayon::prelude::*;
use std::{env, fs, path::PathBuf, process::Command, sync::Mutex};

pub fn main(path: &PathBuf, command: &str) {
    let git_dirs = collect_git_dirs(path);

    git_dirs.par_iter().for_each(|git_dir| {
        let output = Command::new("git")
            .arg(command)
            .current_dir(&git_dir)
            .output()
            .expect("Failed to execute git status");

        let output_str = String::from_utf8_lossy(&output.stdout);
        if !output_str.contains("nothing to commit, working tree clean") {
            println!("Uncommitted changes in: {}", git_dir.display());
        }
    });
}


fn collect_git_dirs(path: &PathBuf) -> Vec<PathBuf> {
    let git_dirs = Mutex::new(Vec::new());
    if let Ok(entries) = fs::read_dir(&path) {
        entries.par_bridge().for_each(|entry| {
            if let Ok(entry) = entry {
                if entry.path().is_dir() {
                    let git_dir = entry.path().join(".git");
                    if git_dir.is_dir() {
                        let mut git_dirs = git_dirs.lock().unwrap();
                        git_dirs.push(entry.path().to_path_buf());
                    } else {
                        let mut git_dirs = git_dirs.lock().unwrap();
                        git_dirs.extend(collect_git_dirs(&entry.path()));
                    }
                }
            }
        });
    } else {
        println!("Failed to read directory");
    }
    git_dirs.into_inner().unwrap()
}
