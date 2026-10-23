class VerificationsController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :require_profile
  before_action :set_pending_member
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Too many tries. Wait a few minutes and try again." }

  def new
  end

  def create
    if @member.verify_sign_in_code(params[:code])
      session.delete(:pending_member_id)
      start_new_session_for @member
      redirect_to after_authentication_url
    elsif @member.sign_in_code_usable?
      flash.now[:alert] = "That code didn't match. Check the message and try again."
      render :new, status: :unprocessable_entity
    else
      session.delete(:pending_member_id)
      redirect_to new_session_path, alert: "That code has expired. Enter your number to get a new one."
    end
  end

  private
    def set_pending_member
      @member = Member.find_by(id: session[:pending_member_id])
      redirect_to new_session_path unless @member
    end
end
