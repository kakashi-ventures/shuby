Jumpstart.config = Jumpstart::Configuration.new(
  "application_name" => "Shuby",
  "business_name" => "Shuby S.r.l",
  "business_address" => "Via Sant'Antonino 17\nTorino, Italy.",
  "domain" => "shuby.app",
  "support_email" => "maryam@kakashi.ventures",
  "default_from_email" => "maryam@kakashi.ventures",
  "background_job_processor" => "solid_queue",
  "email_provider" => "postmark",
  "account_types" => "both",
  "apns" => true,
  "fcm" => true,
  "integrations" => [],
  "omniauth_providers" => [],
  "payment_processors" => ["stripe"],
  "multitenancy" => nil,
  "gems" => []
)
