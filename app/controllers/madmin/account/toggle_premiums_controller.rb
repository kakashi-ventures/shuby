# frozen_string_literal: true

class Madmin::Account::TogglePremiumsController < Madmin::ApplicationController
  def create
    account = ::Account.find(params[:account_id])

    if account.premium?
      # Cancel the fake subscription
      account.payment_processor.subscription&.cancel_now!
      action = "rimosso da Premium"
    else
      # Create a fake premium subscription
      account.set_payment_processor :fake_processor, allow_fake: true
      account.payment_processor.subscribe(plan: :free)
      action = "promosso a Premium"
    end

    redirect_to main_app.madmin_account_path(account), notice: "#{account.name} #{action}.", status: :see_other
  end
end
