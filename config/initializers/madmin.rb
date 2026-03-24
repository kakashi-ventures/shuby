Madmin.site_name = Jumpstart.config.application_name

Madmin.menu.before_render do
  add label: "Sidekiq", url: Rails.application.routes.url_helpers.madmin_sidekiq_web_path, position: 1 if defined? ::Sidekiq::Web
  add label: "Contenuti Shuby", position: 2
  add label: "Sviluppo e Questionari", position: 3
  add label: "Users & Accounts", position: 4
  add label: "Payments", position: 5
  add label: "Sistema", position: 6
end
