class EnsureAllSolidQueueTables < ActiveRecord::Migration[8.1]
  # The production shuby-db is missing all solid_queue_* tables (not just
  # recurring_*). The previous bin/render-build.sh silenced db:schema:load
  # errors with `2>/dev/null || true`, which masked Rails'
  # ProtectedEnvironmentError — the schema was never loaded on the shared
  # primary DB to begin with. When SolidQueue ran inside Puma
  # (SOLID_QUEUE_IN_PUMA=true) it apparently silently worked around this
  # somehow, or the tables got partially populated and later dropped.
  # Regardless, now we need a single versioned migration that creates all
  # SolidQueue tables if missing. Idempotent via `if_not_exists: true`.
  #
  # Table definitions mirror db/queue_schema.rb verbatim.
  def up
    create_table :solid_queue_blocked_executions, if_not_exists: true do |t|
      t.string :concurrency_key, null: false
      t.datetime :created_at, null: false
      t.datetime :expires_at, null: false
      t.bigint :job_id, null: false
      t.integer :priority, default: 0, null: false
      t.string :queue_name, null: false
    end
    add_index :solid_queue_blocked_executions, [:concurrency_key, :priority, :job_id], name: "index_solid_queue_blocked_executions_for_release", if_not_exists: true
    add_index :solid_queue_blocked_executions, [:expires_at, :concurrency_key], name: "index_solid_queue_blocked_executions_for_maintenance", if_not_exists: true
    add_index :solid_queue_blocked_executions, :job_id, unique: true, name: "index_solid_queue_blocked_executions_on_job_id", if_not_exists: true

    create_table :solid_queue_claimed_executions, if_not_exists: true do |t|
      t.datetime :created_at, null: false
      t.bigint :job_id, null: false
      t.bigint :process_id
    end
    add_index :solid_queue_claimed_executions, :job_id, unique: true, name: "index_solid_queue_claimed_executions_on_job_id", if_not_exists: true
    add_index :solid_queue_claimed_executions, [:process_id, :job_id], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id", if_not_exists: true

    create_table :solid_queue_failed_executions, if_not_exists: true do |t|
      t.datetime :created_at, null: false
      t.text :error
      t.bigint :job_id, null: false
    end
    add_index :solid_queue_failed_executions, :job_id, unique: true, name: "index_solid_queue_failed_executions_on_job_id", if_not_exists: true

    create_table :solid_queue_jobs, if_not_exists: true do |t|
      t.string :active_job_id
      t.text :arguments
      t.string :class_name, null: false
      t.string :concurrency_key
      t.datetime :created_at, null: false
      t.datetime :finished_at
      t.integer :priority, default: 0, null: false
      t.string :queue_name, null: false
      t.datetime :scheduled_at
      t.datetime :updated_at, null: false
    end
    add_index :solid_queue_jobs, :active_job_id, name: "index_solid_queue_jobs_on_active_job_id", if_not_exists: true
    add_index :solid_queue_jobs, :class_name, name: "index_solid_queue_jobs_on_class_name", if_not_exists: true
    add_index :solid_queue_jobs, :finished_at, name: "index_solid_queue_jobs_on_finished_at", if_not_exists: true
    add_index :solid_queue_jobs, [:queue_name, :finished_at], name: "index_solid_queue_jobs_for_filtering", if_not_exists: true
    add_index :solid_queue_jobs, [:scheduled_at, :finished_at], name: "index_solid_queue_jobs_for_alerting", if_not_exists: true

    create_table :solid_queue_pauses, if_not_exists: true do |t|
      t.datetime :created_at, null: false
      t.string :queue_name, null: false
    end
    add_index :solid_queue_pauses, :queue_name, unique: true, name: "index_solid_queue_pauses_on_queue_name", if_not_exists: true

    create_table :solid_queue_processes, if_not_exists: true do |t|
      t.datetime :created_at, null: false
      t.string :hostname
      t.string :kind, null: false
      t.datetime :last_heartbeat_at, null: false
      t.text :metadata
      t.string :name, null: false
      t.integer :pid, null: false
      t.bigint :supervisor_id
    end
    add_index :solid_queue_processes, :last_heartbeat_at, name: "index_solid_queue_processes_on_last_heartbeat_at", if_not_exists: true
    add_index :solid_queue_processes, [:name, :supervisor_id], unique: true, name: "index_solid_queue_processes_on_name_and_supervisor_id", if_not_exists: true
    add_index :solid_queue_processes, :supervisor_id, name: "index_solid_queue_processes_on_supervisor_id", if_not_exists: true

    create_table :solid_queue_ready_executions, if_not_exists: true do |t|
      t.datetime :created_at, null: false
      t.bigint :job_id, null: false
      t.integer :priority, default: 0, null: false
      t.string :queue_name, null: false
    end
    add_index :solid_queue_ready_executions, :job_id, unique: true, name: "index_solid_queue_ready_executions_on_job_id", if_not_exists: true
    add_index :solid_queue_ready_executions, [:priority, :job_id], name: "index_solid_queue_poll_all", if_not_exists: true
    add_index :solid_queue_ready_executions, [:queue_name, :priority, :job_id], name: "index_solid_queue_poll_by_queue", if_not_exists: true

    create_table :solid_queue_scheduled_executions, if_not_exists: true do |t|
      t.datetime :created_at, null: false
      t.bigint :job_id, null: false
      t.integer :priority, default: 0, null: false
      t.string :queue_name, null: false
      t.datetime :scheduled_at, null: false
    end
    add_index :solid_queue_scheduled_executions, :job_id, unique: true, name: "index_solid_queue_scheduled_executions_on_job_id", if_not_exists: true
    add_index :solid_queue_scheduled_executions, [:scheduled_at, :priority, :job_id], name: "index_solid_queue_dispatch_all", if_not_exists: true

    create_table :solid_queue_semaphores, if_not_exists: true do |t|
      t.datetime :created_at, null: false
      t.datetime :expires_at, null: false
      t.string :key, null: false
      t.datetime :updated_at, null: false
      t.integer :value, default: 1, null: false
    end
    add_index :solid_queue_semaphores, :expires_at, name: "index_solid_queue_semaphores_on_expires_at", if_not_exists: true
    add_index :solid_queue_semaphores, [:key, :value], name: "index_solid_queue_semaphores_on_key_and_value", if_not_exists: true
    add_index :solid_queue_semaphores, :key, unique: true, name: "index_solid_queue_semaphores_on_key", if_not_exists: true

    # Foreign keys (all to solid_queue_jobs, on_delete: :cascade)
    [
      :solid_queue_blocked_executions,
      :solid_queue_claimed_executions,
      :solid_queue_failed_executions,
      :solid_queue_ready_executions,
      :solid_queue_recurring_executions,
      :solid_queue_scheduled_executions
    ].each do |from_table|
      unless foreign_key_exists?(from_table, :solid_queue_jobs, column: :job_id)
        add_foreign_key from_table, :solid_queue_jobs, column: :job_id, on_delete: :cascade
      end
    end
  end

  def down
    # Intentionally a no-op: we don't drop tables that may contain critical
    # job state. If you need to revert, do so manually with explicit care.
  end
end
