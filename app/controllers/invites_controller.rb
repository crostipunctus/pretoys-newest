class InvitesController < ApplicationController
  def new
    @member = Member.new
  end

  def create
    @member = Member.new(params.expect(member: %i[ name phone ]).merge(source: :invite, invited_by: current_member))

    if (existing = Member.find_by(phone: @member.phone))
      redirect_to existing, notice: "#{existing.display_name} is already in the circle."
    elsif @member.save(context: :profile)
      redirect_to invite_path(@member)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @member = current_member.invitees.find(params[:id])
  end
end
