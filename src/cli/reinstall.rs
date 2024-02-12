use std::{io::Write, process::{exit, Command}};
use indicatif::{ProgressBar, ProgressStyle};
use owo_colors::OwoColorize;

use crate::{CASKS_INSTALL, FORMULA_INSTALL};




pub fn main() {
        let output = Command::new("which")
            .arg("brew")
            .output()
            .expect("Failed to execute command");

        // If Homebrew is not installed, install it
        if !output.status.success() {
            println!("{}", "Installing Homebrew...".green());
            let pb = ProgressBar::new_spinner();
            pb.set_message("Installing Homebrew...");
            use std::time::Duration;
            pb.enable_steady_tick(Duration::from_millis(100));
    
            let install_output = Command::new("/bin/bash")
                .arg("-c")
                .arg("$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")
                .output()
                .expect("Failed to execute command");
    
            pb.finish_and_clear(); // Clear the spinner after completion
    
            if !install_output.status.success() {
                eprintln!("{}", "Failed to install Homebrew.".red());
                exit(1);
            } else {
                println!("{}", "Homebrew installation successful.".green());
            }
        }

       
        install_formulas();
        install_casks();
}

fn install_formulas() {
    let pb = ProgressBar::new(FORMULA_INSTALL.len() as u64);
    pb.set_style(ProgressStyle::default_bar()
    .template("[{elapsed_precise}] [{bar:40.green}] {pos}/{len} ({eta})")
    .expect("Failed to set template")
    .progress_chars("##-"));

    // Install packages from FORMULA_INSTALL
    for package in FORMULA_INSTALL {
        let install_output = Command::new("brew")
            .arg("install")
            .arg(package)
            .output()
            .expect("Failed to execute command");

    
        if install_output.status.success() {
            pb.inc(1);
            pb.tick();
            std::io::stdout().flush().unwrap();
        } else {
            eprintln!("{}", format!("Failed to install {}", package).red());
            exit(1);
        }
    }
    pb.finish();
}



fn install_casks() {
    let pb = ProgressBar::new(CASKS_INSTALL.len() as u64);
    pb.set_style(ProgressStyle::default_bar()
        .template("[{elapsed_precise}] [{bar:40.green}] {pos}/{len} ({eta})")
        .expect("Failed to set template")
        .progress_chars("##-"));

    // Install casks from CASKS_INSTALL
    for cask in CASKS_INSTALL {
        let install_output = Command::new("brew")
        .args(&["install", "--cask", &cask])
        .output();

        match install_output {
            Ok(output) => {
                if output.status.success() {
                    pb.inc(1);
                    pb.tick();
                    std::io::stdout().flush().unwrap();
                } else {
                    eprintln!("{}", format!("Failed to install {}: {}", cask, String::from_utf8_lossy(&output.stderr)).red());
                    exit(1);
                }
            },
            Err(e) => {
                eprintln!("{}", format!("Error executing command for {}: {}", cask, e).red());
                exit(1);
            }
        }
    }
    pb.finish();
}