# See lib/jumpstart/app/models/meta_tags.rb for more configuration details
ActiveSupport::Reloader.to_prepare do
  MetaTags.default_image = "https://shuby.app/opengraph.png"
  MetaTags.default_title = "I primi 1000 giorni, insieme a te"
  MetaTags.default_description = "Shuby ti aiuta a seguire lo sviluppo del tuo bambino da 0 a 36 mesi. Curve di crescita WHO, questionari scientifici, assistente AI e 100+ articoli."
  # MetaTags.default_twitter_site = "@shuby_app"  # uncomment when Twitter/X account exists
end
