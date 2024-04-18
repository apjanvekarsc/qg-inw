module Qg
  module Inw
    class Engine < ::Rails::Engine
      initializer :assets do |config|
        Rails.application.config.assets.paths << root.join("app", "assets", "images", "inw")
      end
    
      initializer :append_migrations do |app|
        unless app.root.to_s.match "#{root}/"
          config.paths['db/migrate'].expanded.each do |expanded_path|
            app.config.paths['db/migrate'] << expanded_path
          end
        end
      end

      config.before_initialize do                                                      
        config.i18n.load_path += Dir["#{config.root}/config/locales/**/*.yml"]
      end
    end
  end
end
