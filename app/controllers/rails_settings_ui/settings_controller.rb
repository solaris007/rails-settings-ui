class RailsSettingsUi::SettingsController < RailsSettingsUi::ApplicationController
  include RailsSettingsUi::SettingsHelper
  before_action :collection
  before_action :validate_settings, only: :update_all

  def index
  end

  def update_all
    if @errors.any?
      render :index
    else
      coerced_values.each { |name, value| RailsSettingsUi.settings_klass[name] = value }
      redirect_to [:settings]
    end
  end

  private

  def collection
    all_settings = default_settings.merge(RailsSettingsUi.settings_klass.public_send(get_collection_method))
    all_settings_without_ignored = all_settings.reject{ |name, description| RailsSettingsUi.ignored_settings.include?(name.to_sym) }
    @settings = Hash[all_settings_without_ignored]
    @errors = {}
  end

  def validate_settings
    # validation schema accepts hash (http://dry-rb.org/gems/dry-validation/forms/) so we're converting
    # ActionController::Parameters => ActiveSupport::HashWithIndifferentAccess
    @errors = RailsSettingsUi::SettingsFormValidator.new(default_settings, params['settings'].deep_dup.to_unsafe_h).errors
  end

  def coerced_values
    RailsSettingsUi::SettingsFormCoercible.new(default_settings, params['settings'].deep_dup.to_unsafe_h).coerce!
  end

  def default_settings
    RailsSettingsUi.settings_klass.defaults
  end
end
