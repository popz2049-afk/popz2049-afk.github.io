# 02-ai-agent-deploy.tape
# Shows: An AI agent (Claude Code) deploying a use case
# Usage: vhs demos/02-ai-agent-deploy.tape

Output static/videos/ai-agent-deploy.gif
Output static/videos/ai-agent-deploy.mp4

Set Shell "bash"
Set FontSize 22
Set FontFamily "JetBrains Mono"
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set WindowBar Colorful
Set BorderRadius 8
Set Padding 20
Set TypingSpeed 35ms
Set CursorBlink true

# Setup
Hide
Type "export PS1='\\[\\033[1;32m\\]lj@darkskies\\[\\033[0m\\]:\\[\\033[1;34m\\]~/zscaler-deploy-kit\\[\\033[0m\\]$ '"
Enter
Sleep 500ms
Type "clear"
Enter
Sleep 500ms
Show

# Scene 1: Ask the agent
Type "# Let Claude Code handle the deployment"
Enter
Sleep 800ms

Type "claude 'Deploy UC-03 geo-blocking to our ZIA tenant'"
Enter
Sleep 1s

# Scene 2: Agent reasoning
Type@0 "╔══════════════════════════════════════╗"
Enter
Type@0 "║  AGENT: Claude Code                 ║"
Enter
Type@0 "╚══════════════════════════════════════╝"
Enter
Sleep 500ms
Type@0 ""
Enter
Type@0 "Reading CLAUDE.md for project context..."
Enter
Sleep 400ms
Type@0 "Reading use-cases/catalog.json..."
Enter
Sleep 400ms
Type@0 ""
Enter
Type@0 "Found UC-03: Country-Based Geo-Blocking"
Enter
Type@0 "  Product: ZIA"
Enter
Type@0 "  Creates: 2 resources (custom URL category + firewall rule)"
Enter
Type@0 "  Compliance: CMMC AC.L2-3.1.3, SC.L2-3.13.6"
Enter
Sleep 1s

# Scene 3: Plan
Type@0 ""
Enter
Type@0 "Running: terraform plan -target=module.uc03 -parallelism=1"
Enter
Sleep 1.5s
Type@0 ""
Enter
Type@0 "Terraform will perform the following actions:"
Enter
Type@0 ""
Enter
Type@0 "  # zia_url_categories.geo_block_countries will be created"
Enter
Type@0 "  + resource \"zia_url_categories\" \"geo_block_countries\" {"
Enter
Type@0 "      + name       = \"UC03-Geo-Blocked-Countries\""
Enter
Type@0 "      + urls       = [\"*.cn\", \"*.ru\", \"*.kp\", \"*.ir\", \"*.cu\"]"
Enter
Type@0 "    }"
Enter
Type@0 ""
Enter
Type@0 "  # zia_firewall_filtering_rules.geo_block will be created"
Enter
Type@0 "  + resource \"zia_firewall_filtering_rules\" \"geo_block\" {"
Enter
Type@0 "      + name       = \"UC03-Block-Embargoed-Countries\""
Enter
Type@0 "      + action     = \"BLOCK_RESET\""
Enter
Type@0 "      + state      = \"DISABLED\""
Enter
Type@0 "    }"
Enter
Sleep 1s

Type@0 ""
Enter
Type@0 "Plan: 2 to add, 0 to change, 0 to destroy."
Enter
Sleep 1s

# Scene 4: Confirmation
Type@0 ""
Enter
Type@0 "⚠ IMPORTANT: Resources will be created in DISABLED state."
Enter
Type@0 "  Review in ZIA Admin Portal before enabling."
Enter
Type@0 "  ZIA requires activation after changes take effect."
Enter
Type@0 ""
Enter
Type@0 "Proceed with apply? [Y/n] "
Sleep 1.5s
Type@0 "Y"
Enter
Sleep 1s

# Scene 5: Apply
Type@0 ""
Enter
Type@0 "zia_url_categories.geo_block_countries: Creating..."
Enter
Sleep 800ms
Type@0 "zia_url_categories.geo_block_countries: Created (2.1s)"
Enter
Type@0 "zia_firewall_filtering_rules.geo_block: Creating..."
Enter
Sleep 800ms
Type@0 "zia_firewall_filtering_rules.geo_block: Created (1.8s)"
Enter
Sleep 500ms
Type@0 ""
Enter
Type@0 "Apply complete! Resources: 2 added, 0 changed, 0 destroyed."
Enter
Type@0 ""
Enter
Type@0 "✓ UC-03 deployed. Review in ZIA Admin Portal → Firewall Policies."
Enter
Sleep 3s
