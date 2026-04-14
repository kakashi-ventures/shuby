class CreateBetaFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :beta_feedbacks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string     :page_url, null: false
      t.string     :section, null: false
      t.integer    :feedback_type, null: false, default: 0
      t.text       :description, null: false
      t.integer    :severity, default: 0
      t.integer    :status, default: 0
      t.jsonb      :metadata, default: {}
      t.text       :admin_notes
      t.timestamps
    end

    add_index :beta_feedbacks, :section
    add_index :beta_feedbacks, :feedback_type
    add_index :beta_feedbacks, :status
  end
end
