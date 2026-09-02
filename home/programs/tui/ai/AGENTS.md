# Milo's agent instructions

These are common instructions for Milo's agents across all scenarios.

## General Guidelines

* Always address me by my full name: "Milo Tekchandani". Use my name in place of "you", for example.
* Never use the em dash "—". Use plain dash "-" instead
* When writing commit messages, NEVER auto-add your agent name as co-author
* Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
* When writing or substantially editing long Markdown files, put each full sentence on its own line.
  Preserve normal Markdown structure, but avoid wrapping multiple sentences onto one physical line.
* When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
* When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would hit it.
  This makes sure you find the real problem so your fix will actually solve it.
* When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
* Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.

## Code Comments

Comments explain WHY, not WHAT.
Why this needs to be done.
Why we are doing it this way instead of that way.
Why this works when it looks like it should not.
Why the business requires this rule, check, or transformation.
Why you would want to pass this param.

Comments that explain what the code does are redundant if the code is reasonably self-documenting, as it should be.
LLMs have a bad habit of commenting like a tutorial and leaving their thought process in the code.
Do not do that.
Only comment in nonstandard scenarios, where the code is not immediately self explanatory or obvious.
Do not add banner or section-header comments to a file that does not already use them.

## Scope

Do not add features, refactor, or introduce abstractions beyond what the task requires.
A bug fix does not need surrounding cleanup, and a one-shot operation usually does not need a helper.
Do not design for hypothetical future requirements; do the simplest thing that works.
Do not add error handling, fallbacks, or validation for cases that cannot occur.
Trust internal code and framework guarantees, and validate at real boundaries only (user input, external APIs).

## Local Precedent

Before writing a new file, read two or three neighbouring files and follow their structure, naming and idiom, including project-specific helpers, wrappers and option namespaces.
Prefer the project's existing way of doing something over the generically standard way, even when the generic way is more common in the wild.
If there is genuinely no local precedent, say so, then pick the mainstream idiom for that ecosystem.

## Milo's Opinions

When you are working on something that would benefit from being informed by Milo's viewpoints, read ~/OPINIONS.md to understand where he stands before deciding.
If there isn't an opinion in regards to the topic / choice / tech stack, ask about it, and then write it into the file where appropriate.
Alternatively, the choice might be a one off.

## Voice Profile

When you are talking/posting on behalf of Milo using his identity, read ~/VOICE.md to see how Milo talks.
