# frozen_string_literal: true

# Controller for Archive educational content
# Displays browsable educational materials for parents about child development
class ArchiveController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content, only: [:show]

  # GET /archive
  # Lists all published archive content organized by sections
  def index
    @favorite_ids = current_user_favorite_ids

    if params[:type] == "saved"
      load_saved_content
    elsif params[:type].present?
      load_filtered_content
    else
      load_sectioned_content
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /archive/:id
  # Displays a single archive content item
  def show
    @favorited = current_user.archive_favorites.exists?(archive_content: @content)
    @related_articles = load_related_articles
  end

  private

  def base_scope
    ArchiveContent.published
  end

  def current_user_favorite_ids
    Set.new(current_user.archive_favorites.pluck(:archive_content_id))
  end

  # Load content for the sectioned home view, age-filtered when a child is selected
  def load_sectioned_content
    scope = age_filtered_scope
    @articles = scope.articles.ordered.limit(4)
    @consigli = scope.tips.ordered.limit(4)
    @activities = scope.activities.ordered.limit(4)
    @sectioned_view = true
  end

  def age_filtered_scope
    return base_scope unless current_child
    base_scope.for_age(current_child.questionnaire_age_in_months)
  end

  # Load saved/favorited content
  def load_saved_content
    @contents = base_scope.where(id: @favorite_ids.to_a).ordered
    @active_type = "saved"
    @sectioned_view = false
  end

  # Load filtered content for type-specific views
  def load_filtered_content
    @contents = base_scope
    @active_type = params[:type] if ArchiveContent.content_types.key?(params[:type])
    @contents = @contents.by_type(@active_type) if @active_type

    # Filter by age range
    if params[:age].present?
      @contents = @contents.for_age(params[:age].to_i)
      @selected_age = params[:age].to_i
    end

    # Filter by category
    if params[:category].present?
      @contents = @contents.where(category: params[:category])
      @selected_category = params[:category]
    end

    @contents = @contents.ordered

    # Get unique categories for filter dropdown
    @categories = ArchiveContent.published
      .distinct
      .pluck(:category)
      .compact
      .sort
    @sectioned_view = false
  end

  def load_related_articles
    base_scope
      .where.not(id: @content.id)
      .where(min_age_months: ..@content.max_age_months, max_age_months: @content.min_age_months..)
      .ordered
      .limit(4)
  end

  def set_content
    @content = ArchiveContent.published.find_by(slug: params[:id])
    @content ||= ArchiveContent.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to archive_index_path, alert: t("archive.not_found")
  end
end
