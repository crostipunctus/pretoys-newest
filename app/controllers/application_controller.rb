class ApplicationController < ActionController::Base
  include Authentication

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_profile

  private
    # Members imported from the group only have a phone number until they tell us their name.
    def require_profile
      if authenticated? && current_member.name.blank?
        redirect_to edit_profile_path, notice: "Welcome! Tell the circle who you are."
      end
    end

    def require_admin
      redirect_to root_path, alert: "Only circle admins can do that." unless current_member&.admin?
    end
end
