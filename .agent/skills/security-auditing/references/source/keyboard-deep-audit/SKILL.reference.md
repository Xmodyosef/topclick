---
name: keyboard-deep-audit
description: Deep audit loop for iOS keyboard extension bugs. Merges diagnosing-bugs + ios-keyboard-limitations + verification-before-completion. Use when emoji grid is empty, sounds silent, hold values wrong, symbols misaligned, or any runtime failure inside a keyboard extension.
---

# Keyboard Deep Audit

Combines three disciplines: tight feedback loops for hard bugs, iOS keyboard extension constraints, and evidence-before-claims verification.

## Phase 0: iOS Keyboard Constraints (always check first)

- Microphone DISALLOWED in keyboard extensions.
- Opening other apps BLOCKED.
- Memory limit 30-60MB. Silent crash if exceeded. No crash logs.
- Persistence ONLY via App Groups. No UserDefaults for cross-process data.
- Network requires Full Access enabled by user.
- AVAudioSession category playback can conflict with host app audio. ambient + mixWithOthers is safer.
- Bundle size matters: every PNG and JSON counts against the memory ceiling.

## Phase 1: Build a feedback loop

This is the skill. If you have a tight pass/fail signal, you will find the cause.

1. Failing test at the seam reaching the bug.
2. CLI invocation with fixture input, diffing stdout.
3. Headless script driving the keyboard UI.
4. Replay a captured trace.
5. Throwaway harness exercising one code path.
6. Property/fuzz loop for sometimes-wrong output.
7. Bisection harness between two known states.
8. Differential loop: old version vs new version.

Tighten: faster, sharper signal, more deterministic.

Non-deterministic bugs: raise reproduction rate until debuggable. 50% flake is debuggable; 1% is not.

If you cannot build a loop: stop. List what you tried. Ask for access, a captured artifact, or permission to add instrumentation.

Completion: one command already run, red-capable, deterministic, fast, agent-runnable.

## Phase 2: Reproduce + minimise

Run the loop. Confirm it produces the user's exact symptom. Shrink until every element is load-bearing.

## Phase 3: Hypothesise

3-5 ranked falsifiable hypotheses. Show to user before testing. Format: If X is the cause, then changing Y makes it disappear.

## Phase 4: Instrument

One variable at a time. Debugger first, targeted logs second. Tag every log [DEBUG-xxxx]. Never log everything.

## Phase 5: Fix + regression test

Write the test before the fix if a correct seam exists. Watch it fail, apply fix, watch it pass, re-run original loop.

## Phase 6: Cleanup + Verification Gate

NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.

Before claiming done:
1. IDENTIFY the command that proves it.
2. RUN it fresh.
3. READ full output, exit code, failure count.
4. VERIFY output confirms the claim.
5. ONLY THEN claim.

Red flags: should, probably, seems, Great!, Perfect!, Done! before verification.
