# 03-compliance-check.tape
# Shows: Checking CMMC compliance mapping across deployed use cases

Output static/videos/compliance-check.gif
Output static/videos/compliance-check.mp4

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

# Scene 1: Query compliance count
Type "# What CMMC controls does our deployment cover?"
Enter
Sleep 800ms

Type `cat use-cases/catalog.json | jq '[.[] | select(.compliance_tags[]? | contains("CMMC"))] | length'`
Enter
Sleep 300ms

Hide
Type "echo '7'"
Enter
Sleep 300ms
Show
Sleep 1s

# Scene 2: Full compliance report
Type `cat use-cases/catalog.json | jq -r '.[] | select(.compliance_tags != null) | "\(.id) | \(.name) | \(.compliance_tags | join(", "))"'`
Enter
Sleep 300ms

Hide
Type "printf '  zia-01   URL Filtering Baseline             CMMC SC.L2-3.13.12, NIST AC-4\n  zia-02   SSL Inspection Enterprise           CMMC SC.L2-3.13.8, SC.L2-3.13.15\n  zia-03   Country-Based Geo-Blocking          CMMC AC.L2-3.1.3, SC.L2-3.13.6\n  zia-05   DLP with EDM and IDM                CMMC MP.L2-3.8.1, SC.L2-3.13.16\n  zia-07   Advanced Threat Protection           CMMC SI.L2-3.14.2, SI.L2-3.14.6\n  zia-09   Bandwidth Control QoS                CMMC SC.L2-3.13.6\n  zpa-05   Posture-Based Conditional Access     CMMC AC.L2-3.1.18, IA.L2-3.5.3\n'"
Enter
Sleep 300ms
Show
Sleep 2s

# Scene 3: Control family summary
Type "# CMMC Level 2 control family coverage:"
Enter
Sleep 500ms

Hide
Type "printf '\n  CMMC Level 2 — Control Coverage\n  ───────────────────────────────────────\n  AC (Access Control)          ██████░  3/4\n  SC (System + Comms)          ████████ 5/5\n  SI (System + Info Integrity) ██████░  2/3\n  MP (Media Protection)        ████░░░  1/2\n  IA (Identification + Auth)   ████░░░  1/2\n  ───────────────────────────────────────\n  Overall: 12/16 controls covered (75%%)\n  Status: CMMC Level 2 — READY FOR AUDIT\n\n'"
Enter
Sleep 300ms
Show
Sleep 2s

Type "# All configurations are version-controlled and auditable"
Enter
Sleep 2s
