class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  skip_before_action :require_profile
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Too many tries. Wait a few minutes and try again." }

  def new
    redirect_to root_path if authenticated?
  end

  def create
    if (member = Member.find_by(phone: params[:phone]))
      code = member.issue_sign_in_code
      SignInCodeDelivery.deliver(member.phone, code)
      session[:pending_member_id] = member.id
      flash[:dev_code] = code if Rails.env.development?
      redirect_to new_verification_path
    else
      flash.now[:alert] = "That number isn't in the circle yet. Pretoys is invite-only: ask a mom who's already a member to add you."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
