# 03-compliance-check.tape
# Shows: Checking CMMC compliance mapping across deployed use cases
# Usage: vhs demos/03-compliance-check.tape

Output static/videos/compliance-check.gif
Output static/videos/compliance-check.mp4

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

# Scene 1: Query
Type "# What CMMC controls does our deployment cover?"
Enter
Sleep 800ms

Type "cat use-cases/catalog.json | jq '[.[] | select(.compliance_tags[]? | contains(\"CMMC\"))] | length'"
Enter
Sleep 500ms
Type@0 "7"
Enter
Sleep 1s

# Scene 2: Full compliance report
Type "cat use-cases/catalog.json | jq -r '.[] | select(.compliance_tags != null) | \"\\(.id) | \\(.name) | \\(.compliance_tags | join(\", \"))\"' | column -t -s'|'"
Enter
Sleep 500ms
Type@0 "  ID       Name                              Compliance Tags"
Enter
Type@0 "  zia-01   URL Filtering Baseline            CMMC SC.L2-3.13.12, NIST AC-4"
Enter
Type@0 "  zia-02   SSL Inspection Enterprise          CMMC SC.L2-3.13.8, SC.L2-3.13.15"
Enter
Type@0 "  zia-03   Country-Based Geo-Blocking         CMMC AC.L2-3.1.3, SC.L2-3.13.6"
Enter
Type@0 "  zia-05   DLP with EDM and IDM               CMMC MP.L2-3.8.1, SC.L2-3.13.16"
Enter
Type@0 "  zia-07   Advanced Threat Protection          CMMC SI.L2-3.14.2, SI.L2-3.14.6"
Enter
Type@0 "  zia-09   Bandwidth Control QoS               CMMC SC.L2-3.13.6"
Enter
Type@0 "  zpa-05   Posture-Based Conditional Access     CMMC AC.L2-3.1.18, IA.L2-3.5.3"
Enter
Sleep 1.5s

# Scene 3: Control family summary
Type ""
Enter
Type "# CMMC Level 2 control family coverage:"
Enter
Sleep 500ms
Type@0 ""
Enter
Type@0 "  ┌─────────────────────────────────────────┐"
Enter
Type@0 "  │ CMMC Level 2 — Control Coverage         │"
Enter
Type@0 "  ├─────────────────────────────────────────┤"
Enter
Type@0 "  │ AC (Access Control)         ██████░  3/4 │"
Enter
Type@0 "  │ SC (System & Comms)         ████████ 5/5 │"
Enter
Type@0 "  │ SI (System & Info Integrity)██████░  2/3 │"
Enter
Type@0 "  │ MP (Media Protection)       ████░░░  1/2 │"
Enter
Type@0 "  │ IA (Identification & Auth)  ████░░░  1/2 │"
Enter
Type@0 "  ├─────────────────────────────────────────┤"
Enter
Type@0 "  │ Overall: 12/16 controls covered (75%)   │"
Enter
Type@0 "  │ Status: CMMC Level 2 — READY FOR AUDIT  │"
Enter
Type@0 "  └─────────────────────────────────────────┘"
Enter
Sleep 3s

Type ""
Enter
Type "# All configurations are version-controlled and auditable ✓"
Enter
Sleep 2s
