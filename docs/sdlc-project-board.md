# SDLC Project Board — Status Label Mapping & Maintenance

The canonical project board for Workarea development tracking is:

**Workarea — SDLC**: <https://github.com/orgs/workarea-commerce/projects/14>

## Column ↔ Label Mapping

Each project board column corresponds to a `status:*` label on the issue/PR. Keep them in sync when work moves between stages.

| Board Column        | Label                      |
|---------------------|----------------------------|
| Todo                | `status:ready`             |
| In Progress         | `status:in-progress`       |
| Ready for Review    | `status:ready-for-review`  |
| Changes Requested   | `status:changes-requested` |
| Blocked             | `status:blocked`           |
| Done                | `status:done`              |

## Maintenance Commands

### Add an issue or PR to the board

```sh
ITEM_ID=$(gh project item-add 14 --owner workarea-commerce \
  --url "https://github.com/workarea-commerce/workarea/issues/NNN" \
  --format json --jq '.id')
```

Replace `NNN` with the issue or PR number. For PRs, swap `issues` for `pull` in the URL.

### Move an item to a column (set status)

```sh
gh project item-edit --project-id PVT_kwDOAwZN_M4BPqxn --id "$ITEM_ID" \
  --field-id "PVTSSF_lADOAwZN_M4BPqxnzg-Auns" \
  --single-select-option-id "<OPTION_ID>"
```

#### Column option IDs

| Column              | `--single-select-option-id` |
|---------------------|-----------------------------|
| Todo                | `aaf906e1`                  |
| In Progress         | `e7c7408c`                  |
| Ready for Review    | `7e314050`                  |
| Changes Requested   | `9e8a5b95`                  |
| Blocked             | `b18e42c9`                  |
| Done                | `ece9591d`                  |

### Full example: move issue #916 to "In Progress"

```sh
# 1. Add to board and capture the item ID
ITEM_ID=$(gh project item-add 14 --owner workarea-commerce \
  --url "https://github.com/workarea-commerce/workarea/issues/916" \
  --format json --jq '.id')

# 2. Set the column
gh project item-edit --project-id PVT_kwDOAwZN_M4BPqxn --id "$ITEM_ID" \
  --field-id "PVTSSF_lADOAwZN_M4BPqxnzg-Auns" \
  --single-select-option-id "e7c7408c"

# 3. Update the label to match
gh issue edit 916 --repo workarea-commerce/workarea \
  --remove-label "status:ready" \
  --add-label "status:in-progress"
```

## Conventions

- **Labels are the source of truth** for status; the project board column should mirror the label.
- When picking up work, add the `status:in-progress` label **and** move the board card simultaneously.
- When opening a PR, swap `status:in-progress` → `status:ready-for-review` on both the issue and the linked PR.
- Automation (if configured) may handle board moves automatically when labels change. Until then, update both manually using the commands above.
