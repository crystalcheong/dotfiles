# Git Workflow (Terminal-first) for Doom

Use terminal Git as your primary flow. Use Magit for visual status, staging, and history.

## Open terminal inside Emacs

- `SPC o t`: toggle vterm popup
- `SPC o T`: open vterm in current directory
- Fallback: `M-x shell` if vterm is unavailable

## Daily terminal Git flow

```bash
git status
git add -A
git commit -S -m "your message"
git push
```

## Verify signed commits

```bash
git log --show-signature -1
git show --show-signature <commit_sha>
git verify-commit <commit_sha>
git log --pretty='%h %G? %s'
```

`%G?` legend: `G` good, `B` bad, `N` none.

## Magit companion keys

- `SPC g g`: open Magit status
- `g`: refresh status
- `s`: stage item at point
- `u`: unstage item at point
- `S`: stage all
- `k`: discard at point
- `c c`: create commit
- `c a`: amend last commit
- `P p`: push current branch
- `l l`: view log
- `q`: quit Magit buffer

## Recommended split of responsibilities

- Use terminal for:
  - signed commits (`-S`)
  - rebase workflows
  - conflict-heavy operations
  - one-liner git commands from muscle memory
- Use Magit for:
  - visual staging of hunks
  - branch/log exploration
  - quick status overview

## Conflict playbook

### Magit + Ediff flow

1. `SPC g g` to open Magit status.
2. In `Unmerged`, move to a conflicted file and press `e` (or `RET`) to resolve.
3. In Ediff:
   - `n` / `p`: next or previous conflict
   - `a` / `b`: take A or B version
   - `q`: quit Ediff
4. Save the file and return to Magit.
5. Stage resolved file with `s`.
6. Finish operation:
   - merge: `c c`
   - rebase/cherry-pick: continue from terminal (`git rebase --continue` / `git cherry-pick --continue`)

### Terminal-first fallback

```bash
git status
# resolve markers in editor
git add <resolved-files>
git commit                # merge
# or:
git rebase --continue     # rebase
git cherry-pick --continue
```
