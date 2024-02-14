import click
import os
import subprocess
import shlex

@click.group()
def cli():
    pass

@cli.command(name='git_checkFolders')
@click.argument('root_folder', type=click.Path(exists=True))
def git_checkfolders(root_folder):
    """Check if subfolders of FOLDER are committed."""
    for dirpath, dirnames, _ in os.walk(root_folder):
        for dirname in dirnames:
            folder = os.path.join(dirpath, dirname)
            if os.path.isdir(os.path.join(folder, '.git')):
                try:
                    result = subprocess.run(['git', '-C', folder, 'status'], capture_output=True, text=True)
                    if 'nothing to commit' not in result.stdout:
                        click.echo(f"Uncommitted changes detected at: {folder}")
                except Exception as e:
                    pass 
            else:
                pass 
            

def read_apps_from_file(filename):
    with open(filename, 'r') as file:
        return [line.strip() for line in file]
    
# Manually split the APPS list into formulas and casks
formulas = [
    'cmake',
    'gh',
    'gradle',
    'jenv',
    'neovim',
    'spicetify-cli',
    'tmux'
]

casks = [
    'wezterm',
    'neovide',
    'raycast',
]


def is_cask(formula_name):
    try:
        # List all casks
        casks = subprocess.check_output(['brew', 'list', '--casks'], text=True).splitlines()
        return formula_name in casks
    except subprocess.CalledProcessError:
        return False


@click.group()
def reinstall():
    """Reinstall apps from Homebrew."""
    pass

@reinstall.command(name='formulas')
def reinstall_formulas():
    """Reinstall all Homebrew formulas."""
    for formula_name in formulas:
        if not is_cask(formula_name):
            reinstall_app(formula_name)

@reinstall.command(name='casks')
def reinstall_casks():
    """Reinstall all Homebrew casks."""
    for formula_name in casks:
        if is_cask(formula_name):
            reinstall_app(formula_name)


def reinstall_app(formula_name):
    try:
        # Update Homebrew
        subprocess.check_call(['brew', 'update'])
        
        # Check if the symlink already exists and remove it if necessary
        symlink_target = f"/opt/homebrew/bin/{formula_name}"
        if os.path.exists(symlink_target):
            os.remove(symlink_target)
        
        # Determine if the item is a cask
        is_cask_item = is_cask(formula_name)
        
        # Unlink the app or cask
        if not is_cask_item:
            try:
                subprocess.check_call(['brew', 'unlink', formula_name])
            except subprocess.CalledProcessError:
                pass
        
        # Reinstall the app or cask
        if is_cask_item:
            subprocess.check_call(['brew', 'install', '--cask', formula_name])
        else:
            subprocess.check_call(['brew', 'install', formula_name])
        
        # Link the app with --overwrite flag
        try:
            subprocess.check_call(['brew', 'link', '--overwrite', formula_name])
        except subprocess.CalledProcessError:
            pass
    except subprocess.CalledProcessError:
        pass

cli.add_command(reinstall)


@cli.command(name='link_folders')
@click.argument('root_folder', type=click.Path(exists=True))
@click.option('--target', default='~/links', help='Target directory for symbolic links.')
def link_folders(root_folder, target):
    """Create a symbolic link from ROOT_FOLDER to TARGET."""
    target = os.path.expanduser(target)
    if not os.path.exists(target):
        subprocess.run(['ln', '-s', root_folder, target], check=True)
        click.echo(f"Created link: {target} -> {root_folder}")
    else:
        click.echo(f"Link already exists: {target}")


if __name__ == '__main__':
    cli()

