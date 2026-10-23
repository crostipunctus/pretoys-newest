# Seeds the circle from the WhatsApp group: paste the group's numbers (or a
# chat export), review what was found, then add them as founding members.
class Admin::ImportsController < Admin::BaseController
  def new
  end

  def preview
    @text = params[:text].to_s
    @entries = PhoneNumber.extract(@text)
    @existing = Member.where(phone: @entries.map(&:phone)).pluck(:phone).to_set

    if @entries.empty?
      flash.now[:alert] = "No phone numbers found. Paste one number per line, or the text of a chat export."
      render :new, status: :unprocessable_entity
    end
  end

  def create
    rows = params.permit(members: %i[ phone name include ]).fetch(:members, {}).to_h.values
    added = rows.count do |row|
      row["include"] == "1" && Member.create(phone: row["phone"], name: row["name"], source: :whatsapp_group).persisted?
    end

    redirect_to members_path, notice: "Added #{helpers.pluralize(added, "member")} from the WhatsApp group. They can now sign in with their number."
  end
end
