class Admin::MembersController < Admin::BaseController
  def destroy
    member = Member.find(params[:id])

    if member == current_member
      redirect_to members_path, alert: "You can't remove yourself."
    else
      member.destroy!
      redirect_to members_path, notice: "#{member.display_name} was removed from the circle, along with their listings.", status: :see_other
    end
  end
end
