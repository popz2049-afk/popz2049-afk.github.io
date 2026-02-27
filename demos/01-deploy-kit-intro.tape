# 01-deploy-kit-intro.tape
# Shows: Cloning the kit, running setup, launching the TUI

Output static/videos/deploy-kit-intro.gif
Output static/videos/deploy-kit-intro.mp4

Set FontSize 22
Set FontFamily "JetBrains Mono"
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set WindowBar Colorful
Set BorderRadius 8
Set Padding 20
Set TypingSpeed 40ms
Set CursorBlink true
Set Framerate 24

# Hidden setup
Hide
Type "export PS1='lj@darkskies:~$ '"
Enter
Type "clear"
Enter
Sleep 500ms
Show

# Scene 1: Clone
Type "# Zscaler Deploy Kit — Zero to First Deploy"
Enter
Sleep 1s

Type "git clone https://github.com/popz2049-afk/zscaler-deploy-kit.git"
Enter
Sleep 500ms

Hide
Type "printf 'Cloning into zscaler-deploy-kit...\nremote: Enumerating objects: 154, done.\nremote: Total 154 (delta 0), reused 154 (delta 0)\nReceiving objects: 100%% (154/154), done.\n'"
Enter
Sleep 300ms
Show
Sleep 1s

Type "cd zscaler-deploy-kit && ls"
Enter
Sleep 300ms

Hide
Type "printf 'CLAUDE.md     README.md      modules/     use-cases/     tui/\nvariables.tf  requirements.txt  setup.sh   docker/        docs/\n'"
Enter
Sleep 300ms
Show
Sleep 1.5s

# Scene 2: Setup
Type "# One-command bootstrap"
Enter
Sleep 500ms
Type "./setup.sh"
Enter
Sleep 300ms

Hide
Type "printf 'Detected: macOS arm64\nTerraform v1.7.5 already installed\nPython 3.12.1 already installed\nCreating virtual environment...\nInstalling dependencies... textual, rich, python-dotenv\nRunning terraform init in modules/zia/...\nRunning terraform init in modules/zpa/...\n\nSetup complete! Run: python tui/app.py\n'"
Enter
Sleep 300ms
Show
Sleep 2s

# Scene 3: Launch TUI
Type "python tui/app.py"
Enter
Sleep 300ms

Hide
Type "printf '\n  ZSCALER DEPLOY KIT — TUI v1.0\n\n  [1] Browse Use Cases (26)    [4] Status\n  [2] Configure Credentials    [5] Rollback\n  [3] Deploy                   [6] Exit\n\n'"
Enter
Sleep 300ms
Show
Sleep 3s
