use std::process::Command;

const APPS_TO_INSTALL: &[&str] = &["git", "bun", "rust"];

#[cfg(target_os = "windows")]
pub fn main() {
    use std::process;

    const WINDOWS_APPS: &[&str] = &[""];
    let scoop_check = Command::new("scoop")
    .arg("--version")
    .output();

if scoop_check.is_err() {
    println!("Scoop is not installed. Attempting to install Scoop...");
    let install_scoop = Command::new("powershell")
        .arg("-NoProfile")
        .arg("-ExecutionPolicy")
        .arg("Bypass")
        .arg("-Command")
        .arg("iex ((New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh'))")
        .output()
        .expect("Failed to execute command to install Scoop");

    if !install_scoop.status.success() {
        eprintln!("Failed to install Scoop. Please install Scoop manually and try again.");
        process::exit(1);
    }
}

for app in APPS_TO_INSTALL.iter().chain(WINDOWS_APPS.iter()) {
    println!("Installing {}...", app);
    let output = Command::new("scoop")
        .arg("install")
        .arg(app)
        .output()
        .expect("Failed to execute command");

    if output.status.success() {
        println!("{} installed successfully", app);
    } else {
        eprintln!("Failed to install {}: {}", app, String::from_utf8_lossy(&output.stderr));
    }
}
}

#[cfg(target_os = "macos")]
pub fn main() {
    const MACOS_APPS: &[&str] = &[""];
    for app in APPS_TO_INSTALL.iter().chain(MACOS_APPS.iter()) {
        println!("Installing {}...", app);
        let output = Command::new("brew")
            .arg("install")
            .arg(app)
            .output()
            .expect("Failed to execute command");

        if output.status.success() {
            println!("{} installed successfully", app);
        } else {
            eprintln!(
                "Failed to install {}: {}",
                app,
                String::from_utf8_lossy(&output.stderr)
            );
        }
    }
}

#[cfg(target_os = "linux")]
pub fn main() {
    println!("This program is designed to run on Windows And MacOS. Please Switch to Windows or MacOS to support this command.");
}
