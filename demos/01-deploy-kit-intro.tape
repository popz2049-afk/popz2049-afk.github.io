# 01-deploy-kit-intro.tape
# Shows: Cloning the kit, running setup, launching the TUI
# Usage: vhs demos/01-deploy-kit-intro.tape

Output static/videos/deploy-kit-intro.gif
Output static/videos/deploy-kit-intro.mp4

Set Shell "bash"
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

# Setup
Hide
Type "export PS1='\\[\\033[1;32m\\]lj@darkskies\\[\\033[0m\\]:\\[\\033[1;34m\\]~\\[\\033[0m\\]$ '"
Enter
Sleep 500ms
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
Sleep 1.5s
Type@0 "Cloning into 'zscaler-deploy-kit'..."
Enter
Type@0 "remote: Enumerating objects: 154, done."
Enter
Type@0 "remote: Total 154 (delta 0), reused 154 (delta 0)"
Enter
Type@0 "Receiving objects: 100% (154/154), done."
Enter
Sleep 1s

Type "cd zscaler-deploy-kit && ls"
Enter
Sleep 500ms
Type@0 "CLAUDE.md     README.md      modules/     use-cases/     tui/"
Enter
Type@0 "variables.tf  requirements.txt  setup.sh   docker/        docs/"
Enter
Sleep 1.5s

# Scene 2: Setup
Type "# One-command bootstrap"
Enter
Sleep 500ms
Type "./setup.sh"
Enter
Sleep 1s
Type@0 "Detected: macOS arm64"
Enter
Type@0 "Terraform v1.7.5 ✓ already installed"
Enter
Type@0 "Python 3.12.1 ✓ already installed"
Enter
Type@0 "Creating virtual environment..."
Enter
Type@0 "Installing dependencies... textual, rich, python-dotenv"
Enter
Type@0 "Running terraform init in modules/zia/..."
Enter
Type@0 "Running terraform init in modules/zpa/..."
Enter
Sleep 500ms
Type@0 "✓ Setup complete! Run 'python tui/app.py' to start."
Enter
Sleep 2s

# Scene 3: Launch TUI
Type "python tui/app.py"
Enter
Sleep 1s
Type@0 "╔═══════════════════════════════════════════════════════╗"
Enter
Type@0 "║           ZSCALER DEPLOY KIT — TUI v1.0              ║"
Enter
Type@0 "╠═══════════════════════════════════════════════════════╣"
Enter
Type@0 "║  [1] Browse Use Cases (26)    [4] Status              ║"
Enter
Type@0 "║  [2] Configure Credentials    [5] Rollback             ║"
Enter
Type@0 "║  [3] Deploy                   [6] Exit                 ║"
Enter
Type@0 "╚═══════════════════════════════════════════════════════╝"
Enter
Sleep 3s
