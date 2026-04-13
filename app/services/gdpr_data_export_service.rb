# frozen_string_literal: true

# Exports all personal data for a user in GDPR-compliant JSON format.
# Covers: profile, children, measurements, questionnaires, chats, favorites.
class GdprDataExportService
  def initialize(user)
    @user = user
    @account = user.personal_account
  end

  def call
    {
      exported_at: Time.current.iso8601,
      user: user_data,
      family: family_data,
      children: children_data,
      chats: chats_data
    }.to_json
  end

  private

  def user_data
    {
      name: @user.name,
      email: @user.email,
      created_at: @user.created_at&.iso8601,
      data_sharing_consent: @user.data_sharing_consent
    }
  end

  def family_data
    profile = @account&.family_profile
    return nil unless profile

    {
      languages_count: profile.languages_count,
      children_count: profile.children_count,
      country: profile.country
    }
  end

  def children_data
    return [] unless @account

    @account.children.active.map do |child|
      {
        name: child.name,
        birth_date: child.birth_date&.iso8601,
        sex: child.sex,
        gestational_weeks: child.gestational_weeks,
        measurements: child.measurements.order(:measured_at).map { |m|
          {
            type: m.measurement_type,
            value: m.value,
            percentile: m.percentile,
            measured_at: m.measured_at&.iso8601
          }
        },
        questionnaires: child.questionnaire_sessions.completed.map { |s|
          {
            area: s.age_band_questionnaire&.development_area&.name,
            age_months: s.child_age_months,
            completed_at: s.completed_at&.iso8601,
            progress: s.progress_percentage,
            responses: s.question_responses.map { |r|
              {question: r.question&.body, answer: r.answer}
            }
          }
        }
      }
    end
  end

  def chats_data
    return [] unless @account

    @account.shuby_chats.includes(:messages).map do |chat|
      {
        title: chat.display_title,
        created_at: chat.created_at&.iso8601,
        messages: chat.messages.order(:created_at).map { |m|
          {role: m.role, content: m.content, created_at: m.created_at&.iso8601}
        }
      }
    end
  end
end
