class AddRelationshipToChildToAccountUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :account_users, :relationship_to_child, :integer, default: 0
  end
end
