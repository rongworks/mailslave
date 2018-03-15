# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180315120209) do

  create_table "crono_jobs", force: :cascade do |t|
    t.string   "job_id",                               null: false
    t.text     "log",               limit: 1073741823
    t.datetime "last_performed_at"
    t.boolean  "healthy"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "mail_accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "user_id"
    t.string   "port"
    t.boolean  "ssl"
    t.string   "host"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "login"
    t.text     "password"
    t.index ["user_id"], name: "index_mail_accounts_on_user_id"
  end

  create_table "mailbox_folders", force: :cascade do |t|
    t.string   "name"
    t.integer  "mail_account_id"
    t.boolean  "sync_active"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["mail_account_id"], name: "index_mailbox_folders_on_mail_account_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",         null: false
    t.text     "value"
    t.string   "target_type", null: false
    t.integer  "target_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true
    t.index ["target_type", "target_id"], name: "index_settings_on_target_type_and_target_id"
  end

  create_table "sync_jobs", force: :cascade do |t|
    t.integer  "mail_account_id"
    t.datetime "sync_start"
    t.datetime "sync_end"
    t.integer  "new_entries"
    t.integer  "skipped_entries"
    t.integer  "processed_entries"
    t.text     "info"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["mail_account_id"], name: "index_sync_jobs_on_mail_account_id"
  end

  create_table "user_mail_attachments", force: :cascade do |t|
    t.integer  "user_mail_id"
    t.string   "file"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_mail_id"], name: "index_user_mail_attachments_on_user_mail_id"
  end

  create_table "user_mails", force: :cascade do |t|
    t.string   "from"
    t.string   "to"
    t.string   "replyto"
    t.datetime "receive_date"
    t.string   "envelope_from"
    t.string   "message_id"
    t.string   "cc"
    t.string   "bcc"
    t.string   "subject"
    t.integer  "mail_account_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "mailbox_id"
    t.text     "plain_content"
    t.text     "html_content"
    t.string   "source_file"
    t.string   "checksum"
    t.string   "in_reply_to"
    t.integer  "folder_id"
    t.text     "conversation"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "admin"
    t.string   "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
