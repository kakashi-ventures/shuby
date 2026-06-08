# TODO — follow-ups from the account-resolution bug fix

From the `/shuby-review` of the "child disappeared after editing profile / switching
language" fix. Full context: `docs/UPSTREAM-ISSUES.md` → "Jumpstart Pro divergences".

## Non-compliant (address before relying on the fix broadly)

- [ ] **Add an automated test for the `accounts:reconcile` rake task.**
      `lib/tasks/accounts_reconcile.rake` was validated via a dev dry-run + `APPLY=1`,
      but has no regression test guarding `stray_skip_reason` (the destruction guards).
      A future change could silently widen what it destroys.
      Suggested `test/tasks/accounts_reconcile_test.rb`: assert it targets only empty
      strays — never an account with children/chats/beta-feedback/payment-processor,
      and never a user's sole account. Exercise dry-run + `APPLY=1`.

- [ ] **Decide Shuby's account mode before Q2 2026 launch.**
      App runs `account_types: "both"` but is effectively single-account-per-user;
      legacy accounts are `personal:false` (team-mode era) — the root of this bug
      class. Choose team vs personal deliberately and migrate, or keep "both" with
      the code guards permanently.

## Suggestions (nice-to-have)

- [ ] **Reconcile: also skip accounts with a pending `account_invitation`.**
      When multi-caregiver ships (post-v1, DEC-004), a stray could carry a pending
      caregiver invite; destroying it would drop the invite. Harmless in v1.

- [ ] **Pin the active account in the session when caregiver-sharing ships.**
      Child-aware `fallback_account` keys off membership, so a caregiver invited to a
      child-bearing family could be auto-routed there on login. Long-term fix is
      explicit session-pinned account selection. (DEC-004 defers multi-caregiver, so
      not needed for v1.0.)
