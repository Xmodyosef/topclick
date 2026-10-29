# Deep Review Rules

- Build a complete file inventory before editing.
- Read the relevant `bundle-XX.md` files and cite the bundle names in the report.
- Trace every changed feature across UI, shared settings, App Groups, extension code, configuration, and CI.
- Compare requirements, source, project.yml, Info.plist, entitlements, workflows, and tests.
- Make the smallest safe change, then run focused checks followed by the full available validation.
- Use a second review pass over the final diff. Stop on unresolved critical or high findings.
- Produce a report with: changed files, evidence, unresolved risks, iPhone-only checks, commit, PR, Actions, and IPA links.
