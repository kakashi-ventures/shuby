module DeviceFormat
  # Sets the request variant based upon the user agent
  #
  # For simplicity, we only register a "native" format for Hotwire Native apps
  # but you may add others like "phone", "tablet" to render different partials
  # based upon the device

  extend ActiveSupport::Concern

  included do
    before_action :set_variant_for_device
  end

  private

  def set_variant_for_device
    # Only enable the :native view variant once the user is signed in. The
    # Jumpstart +native.erb partials (notably _navbar.html+native.erb) render
    # empty, pointer-events:none chrome on mobile — fine when native tabs
    # replace navigation, but it strips the only path to sign-in/sign-up on
    # the unauthenticated landing page.
    if hotwire_native_app? && user_signed_in?
      request.variant = :native
    end
  end
end
