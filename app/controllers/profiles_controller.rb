class ProfilesController < ApplicationController
  skip_before_action :require_profile

  def edit
    @member = current_member
  end

  def update
    @member = current_member
    @member.assign_attributes(params.expect(member: %i[ name neighborhood ]))

    if @member.save(context: :profile)
      redirect_to root_path, notice: "Profile saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
