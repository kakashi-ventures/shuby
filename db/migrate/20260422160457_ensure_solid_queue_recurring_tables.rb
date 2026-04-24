class EnsureSolidQueueRecurringTables < ActiveRecord::Migration[8.1]
  # Solid Queue 1.0 added solid_queue_recurring_{tasks,executions} tables that
  # the existing production DB is missing (the original db:schema:load:queue in
  # bin/render-build.sh was silenced with `2>/dev/null || true`, which masked
  # Rails' ProtectedEnvironmentError and left the schema un-updated).
  #
  # Idempotent `if_not_exists: true` lets this migration no-op on any DB
  # that was re-synced via schema:load since. Safe for both prod (missing)
  # and dev (already present from schema.rb load).
  def up
    create_table :solid_queue_recurring_tasks, if_not_exists: true do |t|
      t.text :arguments
      t.string :class_name
      t.string :command, limit: 2048
      t.datetime :created_at, null: false
      t.text :description
      t.string :key, null: false
      t.integer :priority, default: 0
      t.string :queue_name
      t.string :schedule, null: false
      t.boolean :static, default: true, null: false
      t.datetime :updated_at, null: false
    end
    add_index :solid_queue_recurring_tasks, :key, unique: true, name: "index_solid_queue_recurring_tasks_on_key", if_not_exists: true
    add_index :solid_queue_recurring_tasks, :static, name: "index_solid_queue_recurring_tasks_on_static", if_not_exists: true

    create_table :solid_queue_recurring_executions, if_not_exists: true do |t|
      t.datetime :created_at, null: false
      t.bigint :job_id, null: false
      t.datetime :run_at, null: false
      t.string :task_key, null: false
    end
    add_index :solid_queue_recurring_executions, :job_id, unique: true, name: "index_solid_queue_recurring_executions_on_job_id", if_not_exists: true
    add_index :solid_queue_recurring_executions, [:task_key, :run_at], unique: true, name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", if_not_exists: true
  end

  def down
    remove_index :solid_queue_recurring_executions, name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", if_exists: true
    remove_index :solid_queue_recurring_executions, name: "index_solid_queue_recurring_executions_on_job_id", if_exists: true
    drop_table :solid_queue_recurring_executions, if_exists: true

    remove_index :solid_queue_recurring_tasks, name: "index_solid_queue_recurring_tasks_on_static", if_exists: true
    remove_index :solid_queue_recurring_tasks, name: "index_solid_queue_recurring_tasks_on_key", if_exists: true
    drop_table :solid_queue_recurring_tasks, if_exists: true
  end
end
