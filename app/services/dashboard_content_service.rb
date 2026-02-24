# frozen_string_literal: true

# Service for selecting daily dashboard content for a child
# Provides deterministic daily rotation through age-appropriate content
# following the same pattern as DailyMilestoneService
class DashboardContentService
  ACTIVITIES_COUNT = 3
  TIPS_COUNT = 3
  ARTICLES_COUNT = 3

  def self.call(child, date: Date.current)
    new(child, date).call
  end

  def initialize(child, date)
    @child = child
    @date = date
  end

  def call
    age = @child.questionnaire_age_in_months(@date)

    {
      activities: rotate_content(ArchiveContent.published.games.for_age(age).ordered, ACTIVITIES_COUNT),
      tips: rotate_content(ArchiveContent.published.tips.for_age(age).ordered, TIPS_COUNT),
      articles: rotate_articles(ArchiveContent.published.articles.for_age(age).ordered, ARTICLES_COUNT)
    }
  end

  private

  def rotate_content(scope, count)
    pool = scope.to_a
    return pool if pool.size <= count

    offset = seed % pool.size
    pool.rotate(offset).first(count)
  end

  def rotate_articles(scope, count)
    pool = scope.to_a
    return pool if pool.size <= count

    offset = seed % pool.size
    rotated = pool.rotate(offset)

    # First pass: pick one article per distinct category
    selected = []
    seen_categories = Set.new
    rotated.each do |article|
      break if selected.size >= count

      if article.category.blank? || seen_categories.add?(article.category)
        selected << article
      end
    end

    # Second pass: fill remaining slots from whatever's left
    if selected.size < count
      rotated.each do |article|
        break if selected.size >= count
        selected << article unless selected.include?(article)
      end
    end

    selected
  end

  def seed
    @seed ||= @child.id + day_number
  end

  def day_number
    @date.to_time.to_i / 86400
  end
end
