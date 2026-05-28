module PricingHelper
  def pricing_cta(plan)
    (plan.trial_period_days? && (!user_signed_in? || current_account&.pay_subscriptions&.none?)) ? t(".start_trial") : t(".get_started")
  end

  def pricing_link_to(plan, **opts)
    default_options = {class: "shuby-btn shuby-btn-lg shuby-btn-primary w-full"}
    opts = default_options.merge(opts)

    if plan.contact_url.present?
      link_to t(".contact_us"), plan.contact_url, **opts
    else
      link_to pricing_cta(plan), checkout_path(plan: plan), **opts
    end
  end

  # Returns the right CTA element for a plan card based on the current
  # account's subscription state. Free-plan cards never show a CTA — only a
  # "Piano attuale" badge when the user is on the free tier. Paid-plan cards
  # show a badge if the user is subscribed, otherwise the upgrade link.
  def plan_cta_for(plan)
    is_paid = plan.amount.to_i > 0

    if current_account&.premium?
      is_paid ? current_plan_badge : nil
    else
      is_paid ? pricing_link_to(plan) : current_plan_badge
    end
  end

  private

  def current_plan_badge
    tag.span(t("pricing.show.current_plan"), class: "shuby-tag shuby-tag-info")
  end
end
