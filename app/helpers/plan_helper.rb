module PlanHelper
  def formatted_plan_interval(plan)
    t("plan.interval.#{plan.interval}", count: plan.interval_count)
  end
end
