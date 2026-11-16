# PR #131 — Device Validation Protocol

**Status:** protocol only; no device result is implied by this document.  
**PR:** #131 — Fix keyboard page transitions and unify release version  
**Target branch:** `main` (do not merge until owner approval)  
**Build under test:** record the exact IPA artifact, commit SHA, app version, and build number.

## Rules

- CI/source-contract success is not evidence of physical-device behavior.
- Do not mark a test passed unless it was run on the named physical device and the result was recorded.
- Keep CI unsigned. Install only after signing on the owner's iPhone with Feather/eSign. No P12 or signing identity in CI.
- Every failure must include exact reproduction steps, expected result, actual result, device/iOS, build SHA, and relevant logs or screen recording.
- A skipped or unavailable device test is **NOT RUN**, not passed.

## Device matrix

| ID | Device class | Required coverage |
|---|---|---|
| D1 | Home-button iPhone (e.g. iPhone SE) | Globe visibility and handoff |
| D2 | Face ID iPhone | Globe visibility, repeated handoff, layout changes |
| D3 | iPad with keyboard extension support | Rotation and Globe layout (record model/iPadOS) |

If a listed device is unavailable, record NOT RUN and do not infer its result from another device.

## Functional tests

### T1 — Globe on Home-button iPhone
1. Record model and exact iOS version.
2. Enable at least two third-party/system keyboards in Settings.
3. Open a normal text field and invoke Naqra.
4. Verify the Globe/input-mode key is visible.
5. Tap it and verify iOS switches to the next keyboard; switch back.

**Pass:** key is visible and hands off to iOS without freeze, missing key, or extension termination.

### T2 — Globe on Face ID iPhone
Repeat T1 on a Face ID device. Switch away and back at least 10 times, including after dismissing and reopening the keyboard.

**Pass:** every handoff succeeds; the key remains correctly present whenever iOS reports that an input-mode switch key is needed.

### T3 — iPad and rotation
On an iPad, verify Globe visibility, rotate portrait/landscape, and repeat the handoff.

**Pass:** no missing/duplicated key, stuck layout, or extension termination after rotation.

### T4 — `needsInputModeSwitchKey` transition
Do not assume that changing to `secureTextEntry` necessarily changes this property.

1. Use a controlled host app containing ordinary and secure text fields.
2. Enable at least two keyboards and record the initial value while Naqra is active in the ordinary field.
3. Move focus to the secure field without dismissing the keyboard if the host app permits it; record the value and visible Globe state.
4. Return to the ordinary field and repeat.
5. Record the actual property value at `viewWillAppear` and `textDidChange`. A diagnostic-only `viewDidLayoutSubviews` observer may record changes between those callbacks, but must not drive production behavior.
6. Repeat with only one enabled keyboard as a control.

**Pass:** whenever the host/iOS state requires the input-mode switch key, Naqra reflects that state correctly. If the property never changes in the tested scenario, record **INCONCLUSIVE FOR TRANSITION** rather than claiming a defect or a pass for dynamic updates.

### T5 — Arabic/English switching
Switch Arabic ↔ English at least 50 times, including while on the emoji page.

**Pass:** no crash, stuck state, unexpected page reset, or lost input.

### T6 — Emoji insertion and return
Open emoji, insert at least 20 emoji across categories (include a skin-tone variant), then return to letters.

**Pass:** each selected emoji is inserted once; page remains responsive; no stale animation or missing rebuild.

### T7 — Page transitions
Navigate through every available keyboard page and back at least 20 complete cycles.

**Pass:** no crash, frozen control, stale overlay, or page mismatch.

### T8 — Arabic combining marks and deletion
Use a host text field that exposes the resulting text after each action.

Test these exact inputs separately:
- `مُحَمَّد`
- `السَّلَامُ`

For each input:
1. Paste/type the exact string and capture the text before deletion.
2. Delete one user-perceived character at a time using the keyboard's delete interaction.
3. Record the text after every deletion until empty.
4. Repeat using the swipe-delete gesture, then repeat word deletion.
5. Record Unicode scalar values and grapheme-cluster count for diagnosis; judge correctness by the intended visible/user-perceived deletion, not by assuming one scalar equals one character.

**Pass:** no unintended neighboring letter/word deletion, no orphaned combining marks, and the final text matches the expected sequence at every step.

### T9 — Mixed-script deletion
Repeat T8 with Arabic, Latin letters, digits, spaces, and emoji in one string.

**Pass:** deletion follows the expected user-perceived character/word boundaries without over- or under-deletion.

## T10 — Memory characterization

1. Choose one reference physical device and pin its model, exact OS build, power state, and test host app.
2. Use the same warm-up period and scripted path on every run: T5 + T6 + T7, repeated for 10 cycles.
3. Collect at least 5 initial independent runs using Instruments. Record **Peak Resident** and **VM Tracker** separately; do not combine them into one metric.
4. Report each raw observation, mean (μ), sample standard deviation (σ), coefficient of variation (σ/μ), and the exploratory upper reference μ + 3σ for each metric.
5. If coefficient of variation exceeds 15%, mark the run set unstable and investigate the path/measurement conditions. Do not create a threshold from unstable data.
6. Five runs are an initial characterization only. Do not enforce μ + 3σ as a CI failure threshold from this small sample. Collect a larger stable reference set (at least 20 runs) and review measurement noise before considering an automated regression gate.

## Result record

Copy one record per test run:

```text
Test ID / iteration:
Device model:
iOS/iPadOS exact version + build:
Host app / field type:
Naqra app version / build:
IPA artifact URL:
Git SHA:
Date/time:
Preconditions (enabled keyboards, orientation, text):
Steps to reproduce:
Expected:
Actual:
Result: PASS / FAIL / NOT RUN / INCONCLUSIVE
Crash or diagnostic log:
Screen recording / Instruments trace:
Notes:
```

For T4, additionally record:
```text
needsInputModeSwitchKey at viewWillAppear:
needsInputModeSwitchKey at textDidChange:
Diagnostic layout observation (if enabled):
Globe visible:
Number of enabled keyboards:
```

For T8/T9, additionally record:
```text
Exact input:
Text before each deletion:
Text after each deletion:
Expected visible deletion:
Observed visible deletion:
Unicode scalars / grapheme-cluster count (diagnostic):
```

For T10, attach raw measurements and report Peak Resident and VM Tracker independently, including all run values, μ, σ, CV, and whether the set is stable.

## Merge gate

PR #131 is not ready to merge until:
- the latest unsigned IPA build and built-bundle validation succeed;
- automated checks pass for the latest PR head;
- T1–T9 are recorded on the applicable physical devices (unavailable tests remain NOT RUN and block the corresponding claim);
- T10 has a stable, documented reference measurement, or is explicitly recorded as deferred with no CI memory gate claimed;
- no unexplained crash or reproducible data-loss/deletion defect remains;
- the owner reviews the evidence and explicitly approves the merge.

Passing this checklist does not itself authorize merging. Owner approval is still required.
