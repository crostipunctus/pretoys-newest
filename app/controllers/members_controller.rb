class MembersController < ApplicationController
  def index
    members = Member.alphabetical.includes(:invited_by)
    @founders = members.whatsapp_group
    @invited = members.invite
  end

  def show
    @member = Member.find(params[:id])
    @listings = @member.listings.visible.newest_first.with_attached_photos
    @invitees = @member.invitees.alphabetical
  end
end
