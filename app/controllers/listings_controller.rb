class ListingsController < ApplicationController
  # Signed-out visitors (and WhatsApp's link preview) get a teaser of a shared listing.
  allow_unauthenticated_access only: :show
  before_action :set_own_listing, only: %i[ edit update destroy mark ]

  def index
    @listings = Listing.visible.newest_first.includes(:member).with_attached_photos
    @listings = @listings.where(category: params[:category]) if params[:category].present?
    @listings = @listings.where(age_group: params[:age]) if params[:age].present?
    @listings = @listings.free if params[:free] == "1"
    @listings = @listings.search(params[:q]) if params[:q].present?
    @member_count = Member.joined.count
  end

  def mine
    @listings = current_member.listings.newest_first.with_attached_photos
  end

  def show
    @listing = Listing.find_by!(token: params[:id])

    unless authenticated?
      session[:return_to_after_authenticating] = request.url
      render :teaser
    end
  end

  def new
    @listing = current_member.listings.new(neighborhood: current_member.neighborhood, condition: "good")
  end

  def create
    @listing = current_member.listings.new(listing_params)

    if @listing.save
      redirect_to @listing, notice: "Your toy is listed! Share it in the group so moms see it."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @listing.assign_attributes(listing_params.except(:photos))
    @listing.photos.attach(listing_params[:photos]) if listing_params[:photos].present?

    if @listing.save
      @listing.photos.where(id: params[:remove_photo_ids]).each(&:purge_later) if params[:remove_photo_ids].present?
      redirect_to @listing, notice: "Listing updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def mark
    @listing.update!(status: params[:status]) if Listing.statuses.key?(params[:status])
    redirect_to @listing, notice: "Marked as #{@listing.status_label.downcase}."
  end

  def destroy
    @listing.destroy!
    redirect_to mine_listings_path, notice: "Listing deleted.", status: :see_other
  end

  private
    def set_own_listing
      @listing = current_member.listings.find_by!(token: params[:id])
    end

    def listing_params
      params.expect(listing: [ :title, :description, :price, :category, :age_group, :condition, :neighborhood, photos: [] ])
    end
end
