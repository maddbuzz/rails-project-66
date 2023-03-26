# frozen_string_literal: true

module Web
  module Admin
    class ApplicationController < Web::ApplicationController
      layout 'admin_panel'

      before_action :authorize_admin

      private

      def authorize_admin
        return redirect_to root_path, alert: t('user_not_admin') unless current_user&.admin?
      end
    end
  end
end
