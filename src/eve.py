import typer
import os
import subprocess

app = typer.Typer()

@app.command()
def git_checkfolders(root_folder: str):
    """Check if subfolders of FOLDER are committed."""
    for dirpath, dirnames, _ in os.walk(root_folder):
        for dirname in dirnames:
            folder = os.path.join(dirpath, dirname)
            if os.path.isdir(os.path.join(folder, ".git")):
                try:
                    result = subprocess.run(
                        ["git", "-C", folder, "status"], capture_output=True, text=True
                    )
                    if "nothing to commit" not in result.stdout:
                        typer.echo(f"Uncommitted changes detected at: {folder}")
                except Exception as e:
                    pass
            else:
                pass

def read_apps_from_file(filename: str) -> list:
    with open(filename, "r") as file:
        return [line.strip() for line in file]

formulas = ["cmake", "gh", "gradle", "jenv", "neovim", "spicetify-cli", "tmux"]

casks = [
    "wezterm",
    "neovide",
    "raycast",
]

def is_cask(formula_name: str) -> bool:
    try:
        casks = subprocess.check_output(
            ["brew", "list", "--casks"], text=True
        ).splitlines()
        return formula_name in casks
    except subprocess.CalledProcessError:
        return False

reinstall_app = typer.Typer()

@reinstall_app.command()
def formulas():
    """Reinstall all Homebrew formulas."""
    for formula_name in formulas:
        if not is_cask(formula_name):
            reinstall_formula(formula_name)

@reinstall_app.command()
def casks():
    """Reinstall all Homebrew casks."""
    for formula_name in casks:
        if is_cask(formula_name):
            reinstall_formula(formula_name)

def reinstall_formula(formula_name: str):
    try:
        subprocess.check_call(["brew", "update"])

        symlink_target = f"/opt/homebrew/bin/{formula_name}"
        if os.path.exists(symlink_target):
            os.remove(symlink_target)

        is_cask_item = is_cask(formula_name)

        if not is_cask_item:
            try:
                subprocess.check_call(["brew", "unlink", formula_name])
            except subprocess.CalledProcessError:
                pass

        if is_cask_item:
            subprocess.check_call(["brew", "install", "--cask", formula_name])
        else:
            subprocess.check_call(["brew", "install", formula_name])

        try:
            subprocess.check_call(["brew", "link", "--overwrite", formula_name])
        except subprocess.CalledProcessError:
            pass
    except subprocess.CalledProcessError:
        pass

app.add_typer(reinstall_app, name="reinstall")

@app.command()
def link_folders(root_folder: str, target: str = typer.Option(default="~/links", help="Target directory for symbolic links.")):
    """Create a symbolic link from ROOT_FOLDER to TARGET."""
    target = os.path.expanduser(target)
    if not os.path.exists(target):
        subprocess.run(["ln", "-s", root_folder, target], check=True)
        typer.echo(f"Created link: {target} -> {root_folder}")
    else:
        typer.echo(f"Link already exists: {target}")

if __name__ == "__main__":
    app()