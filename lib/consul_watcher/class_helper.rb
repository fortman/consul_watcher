# frozen_string_literal: true

module ConsulWatcher
  # Define methods to handle default initialization behavior
  module ClassHelper
    def populate_variables(config = {})
      defaults.each_pair do |key, default_value|
        key = key.to_s
        if config[key]
          instance_variable_set("@#{key}", config[key])
        elsif ENV[key.upcase.to_s]
          instance_variable_set("@#{key}", ENV[key.upcase.to_s])
        else
          instance_variable_set("@#{key}", default_value)
        end
      end
    end
  end
end
