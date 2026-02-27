# 02-ai-agent-deploy.tape
# Shows: An AI agent (Claude Code) deploying a use case

Output static/videos/ai-agent-deploy.gif
Output static/videos/ai-agent-deploy.mp4

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
Set Framerate 24

# Hidden setup
Hide
Type "export PS1='lj@darkskies:~/zscaler-deploy-kit$ '"
Enter
Type "clear"
Enter
Sleep 500ms
Show

# Scene 1: Ask the agent
Type "# Let Claude Code handle the deployment"
Enter
Sleep 800ms

Type `claude "Deploy UC-03 geo-blocking to our ZIA tenant"`
Enter
Sleep 1s

# Scene 2: Agent reasoning (fake output via printf)
Hide
Type "printf 'AGENT: Claude Code\n\nReading CLAUDE.md for project context...\nReading use-cases/catalog.json...\n\nFound UC-03: Country-Based Geo-Blocking\n  Product: ZIA\n  Creates: 2 resources (custom URL category + firewall rule)\n  Compliance: CMMC AC.L2-3.1.3, SC.L2-3.13.6\n'"
Enter
Sleep 300ms
Show
Sleep 1.5s

# Scene 3: Plan output
Hide
Type "printf '\nRunning: terraform plan -target=module.uc03 -parallelism=1\n\nTerraform will perform the following actions:\n\n'"
Enter
Sleep 300ms
Show
Sleep 1s

Hide
Type 'printf "  # zia_url_categories.geo_block_countries will be created\n  + resource \"zia_url_categories\" \"geo_block_countries\" {\n      + name       = \"UC03-Geo-Blocked-Countries\"\n      + urls       = [\"*.cn\", \"*.ru\", \"*.kp\", \"*.ir\", \"*.cu\"]\n    }\n\n  # zia_firewall_filtering_rules.geo_block will be created\n  + resource \"zia_firewall_filtering_rules\" \"geo_block\" {\n      + name       = \"UC03-Block-Embargoed-Countries\"\n      + action     = \"BLOCK_RESET\"\n      + state      = \"DISABLED\"\n    }\n\nPlan: 2 to add, 0 to change, 0 to destroy.\n"'
Enter
Sleep 300ms
Show
Sleep 2s

# Scene 4: Confirmation
Hide
Type "printf '\nIMPORTANT: Resources will be created in DISABLED state.\n  Review in ZIA Admin Portal before enabling.\n  ZIA requires activation after changes take effect.\n\n'"
Enter
Sleep 300ms
Show
Sleep 1s

Type "# Proceed with apply? [Y/n]"
Enter
Sleep 1s
Type "Y"
Enter
Sleep 1s

# Scene 5: Apply
Hide
Type "printf '\zia_url_categories.geo_block_countries: Creating...\nzia_url_categories.geo_block_countries: Created (2.1s)\nzia_firewall_filtering_rules.geo_block: Creating...\nzia_firewall_filtering_rules.geo_block: Created (1.8s)\n\nApply complete! Resources: 2 added, 0 changed, 0 destroyed.\n\nUC-03 deployed. Review in ZIA Admin Portal > Firewall Policies.\n'"
Enter
Sleep 300ms
Show
Sleep 3s
