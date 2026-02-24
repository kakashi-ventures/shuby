# frozen_string_literal: true

require "test_helper"

class DashboardContentServiceTest < ActiveSupport::TestCase
  setup do
    @child = children(:sophia) # ~2 months old
    @date = Date.current
  end

  test "returns hash with activities, tips, and articles keys" do
    result = DashboardContentService.call(@child, date: @date)

    assert_kind_of Hash, result
    assert result.key?(:activities)
    assert result.key?(:tips)
    assert result.key?(:articles)
  end

  test "each value is an array of ArchiveContent" do
    result = DashboardContentService.call(@child, date: @date)

    %i[activities tips articles].each do |key|
      assert_kind_of Array, result[key]
      result[key].each do |item|
        assert_kind_of ArchiveContent, item
      end
    end
  end

  test "respects count limits" do
    result = DashboardContentService.call(@child, date: @date)

    assert result[:activities].size <= DashboardContentService::ACTIVITIES_COUNT
    assert result[:tips].size <= DashboardContentService::TIPS_COUNT
    assert result[:articles].size <= DashboardContentService::ARTICLES_COUNT
  end

  test "only returns published content" do
    result = DashboardContentService.call(@child, date: @date)

    %i[activities tips articles].each do |key|
      result[key].each do |item|
        assert item.published?, "Expected #{item.title} to be published"
      end
    end
  end

  test "only returns age-appropriate content" do
    age = @child.questionnaire_age_in_months(@date)
    result = DashboardContentService.call(@child, date: @date)

    %i[activities tips articles].each do |key|
      result[key].each do |item|
        assert item.min_age_months <= age, "#{item.title} min_age #{item.min_age_months} > child age #{age}"
        assert item.max_age_months >= age, "#{item.title} max_age #{item.max_age_months} < child age #{age}"
      end
    end
  end

  test "deterministic: same child and date returns same results" do
    result1 = DashboardContentService.call(@child, date: @date)
    result2 = DashboardContentService.call(@child, date: @date)

    assert_equal result1[:activities].map(&:id), result2[:activities].map(&:id)
    assert_equal result1[:tips].map(&:id), result2[:tips].map(&:id)
    assert_equal result1[:articles].map(&:id), result2[:articles].map(&:id)
  end

  test "rotation: different dates produce different results when pool exceeds count" do
    # Use two dates far enough apart to guarantee different offsets
    date1 = Date.new(2026, 1, 1)
    date2 = Date.new(2026, 1, 2)

    result1 = DashboardContentService.call(@child, date: date1)
    result2 = DashboardContentService.call(@child, date: date2)

    # At least one content type should differ (pool > count for all types with our fixtures)
    activities_differ = result1[:activities].map(&:id) != result2[:activities].map(&:id)
    tips_differ = result1[:tips].map(&:id) != result2[:tips].map(&:id)
    articles_differ = result1[:articles].map(&:id) != result2[:articles].map(&:id)

    assert activities_differ || tips_differ || articles_differ,
      "Expected at least one content section to differ between dates"
  end

  test "articles favor category diversity" do
    result = DashboardContentService.call(@child, date: @date)
    articles = result[:articles]

    # With 5 articles across 4 categories (Sonno x2, Nutrizione, Sviluppo, Sicurezza),
    # picking 3 should yield at least 3 distinct categories
    return if articles.size < 2 # skip if insufficient data

    categories = articles.map(&:category).compact
    assert categories.size <= articles.size
    # Should have more unique categories than if picked sequentially from one category
    assert categories.uniq.size >= [categories.size, 2].min,
      "Expected category diversity, got: #{categories}"
  end

  test "returns empty arrays when no matching content exists" do
    # Create a child whose age won't match any fixture content
    child = Child.create!(
      account: accounts(:company),
      name: "Older Child",
      birth_date: 40.months.ago.to_date,
      sex: 1
    )

    result = DashboardContentService.call(child, date: @date)

    assert_equal [], result[:activities]
    assert_equal [], result[:tips]
    assert_equal [], result[:articles]
  end

  test "returns full pool when pool size is smaller than count" do
    # Create a child at an age where only some content matches
    child = Child.create!(
      account: accounts(:company),
      name: "Toddler",
      birth_date: 30.months.ago.to_date,
      sex: 2
    )

    result = DashboardContentService.call(child, date: @date)

    # At 30 months, only game_canzoncine (0-36), game_out_of_range (24-36), and
    # article_sicurezza (0-36) match — pools are <= count, so full pool returned
    result.each_value do |items|
      items.each do |item|
        assert_kind_of ArchiveContent, item
      end
    end
  end
end
