# frozen_string_literal: true

# One-off reconciliation for the "child disappeared after editing profile" bug.
#
# Background: legacy users registered while the app was in team mode own a
# personal:false account holding their children. Once the app started running in
# personal/both mode, the first profile edit minted an EMPTY personal account
# (via a name-change callback), which fallback_account then preferred — hiding the
# user's child. The code guards (app/models/user.rb, app/models/user/accounts.rb,
# app/controllers/concerns/set_current_request_details.rb) stop new strays; this
# task heals the existing data.
#
# Collapses each user to ONE canonical owned account and destroys only the
# provably-empty stray owned accounts. DRY-RUN by default — pass APPLY=1 to act.
#
#   bin/rails accounts:reconcile          # audit only, destroys nothing
#   APPLY=1 bin/rails accounts:reconcile  # actually destroy empty strays
#
# Idempotent: re-running after a successful APPLY reports nothing to do.

namespace :accounts do
  desc "Collapse each user to one canonical account; remove empty stray owned accounts (DRY-RUN unless APPLY=1)"
  task reconcile: :environment do
    apply = ENV["APPLY"] == "1"
    mode = apply ? "APPLY" : "DRY-RUN"

    users_with_multiple = 0
    strays_found = 0
    strays_removed = 0
    strays_skipped = 0

    # Returns nil when an account is a safe-to-destroy empty stray, else the reason
    # it must be kept. Conservative: keeps anything holding data or billing.
    stray_skip_reason = lambda do |account|
      next "has children" if account.children.exists?
      next "has chats" if account.shuby_chats.exists?
      next "has beta feedback" if account.beta_feedbacks.exists?
      next "has payment processor" if account.payment_processor.present?

      nil
    end

    puts "== accounts:reconcile (#{mode}) =="

    User.includes(owned_accounts: :children).find_each do |user|
      owned = user.owned_accounts.to_a
      next if owned.size < 2

      users_with_multiple += 1

      # Canonical = an owned account with active children (oldest wins), else the
      # oldest owned account. Never destroy this one.
      canonical = owned.select { |a| a.children.any?(&:active?) }.min_by(&:created_at) ||
        owned.min_by(&:created_at)

      (owned - [canonical]).each do |account|
        reason = stray_skip_reason.call(account)
        if reason
          strays_skipped += 1
          puts "  SKIP  user=#{user.id} account=#{account.id} (#{account.personal? ? "personal" : "team"}) — #{reason}"
          next
        end

        strays_found += 1
        puts "  STRAY user=#{user.id} account=#{account.id} (#{account.personal? ? "personal" : "team"}) empty — canonical=#{canonical.id}"
        next unless apply

        account.destroy!
        strays_removed += 1
        puts "        destroyed account=#{account.id}"
      end
    end

    puts "-- summary (#{mode}) --"
    puts "  users with >1 owned account: #{users_with_multiple}"
    puts "  empty strays found:          #{strays_found}"
    puts "  strays destroyed:            #{strays_removed}"
    puts "  strays skipped (have data):  #{strays_skipped}"
    puts "  (dry-run — re-run with APPLY=1 to destroy)" unless apply
  end
end
