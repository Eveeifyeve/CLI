import click
import os
import subprocess

@click.group()
def cli():
    pass

@cli.command(name='git_checkFolders')
@click.argument('root_folder', type=click.Path(exists=True))
def git_checkfolders(root_folder):
    """Check if subfolders of ROOT_FOLDER are Git repositories and if they are committed."""
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

if __name__ == '__main__':
    cli()