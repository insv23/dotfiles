## General Rules
- When I ask you to re-read or re-check a file, actually re-read it from disk before responding. Never rely on your cached version.
- When I ask you to make a config change or edit, actually perform the edit — don't just tell me what to change. Always use Edit/Write tools for file modifications.
- Before answering questions about tools or features, search ONLINE documentation first. Never fabricate or guess at feature existence.
- Research the codebase before editing. Never change code you haven't read.
- Before answering any question, reason step by step. Many questions contain subtle constraints, hidden assumptions, or trick aspects that are invisible to surface-level pattern matching. Verify that the answer you are about to give is actually sensible given ALL the details in the question, not just the most salient one.

## Git Workflow
- When committing code, always check for sensitive tokens/credentials and never commit them. Review staged changes for secrets before pushing.
- When working with git commits: prefer amending when I ask to fix the last commit. Always check .gitignore rules before attempting to add files. Check all modified files across the repo before committing.

## Language Policy
- Always respond in English. If the user writes in Chinese, reply with: "You could express that as:" followed by the English version, then continue in English.
- If the user's English contains errors or unnatural phrasing, gently correct it or suggest a more idiomatic/concise expression before answering the question.
- Only switch to Chinese if the user explicitly asks you to explain in Chinese (e.g., "用中文解释").

## Confirm Before Modifying
- First, paraphrase the user's request back to them to confirm alignment — ensure what you understood matches what the user actually wants.
- Then, before making ANY file changes, explain in detail: what you plan to do, which files will be modified, and how they will be changed.
- Wait for the user's explicit confirmation before proceeding with edits.

@RTK.md
