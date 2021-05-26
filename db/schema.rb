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

ActiveRecord::Schema.define(version: 2021_05_26_035533) do

  create_table "devices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.integer "device_id"
    t.string "device_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_token", limit: 24
    t.string "i2c_address", limit: 10
    t.integer "broadcast_to_device_id"
    t.boolean "invert_video", default: false
    t.boolean "video_enabled", default: false
    t.string "control_template"
    t.boolean "public", default: false
    t.string "slug"
    t.datetime "last_active_at"
    t.boolean "public_video", default: false
    t.boolean "audio_enabled", default: false
    t.integer "audio_start_pin"
    t.string "time_zone", limit: 50
    t.time "sleeptime_start"
    t.time "sleeptime_end"
    t.index ["auth_token"], name: "index_devices_on_auth_token", unique: true
    t.index ["broadcast_to_device_id"], name: "index_devices_on_broadcast_to_device_id"
    t.index ["device_id"], name: "index_devices_on_device_id"
    t.index ["slug"], name: "index_devices_on_slug"
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "pins", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "device_id"
    t.string "name"
    t.string "pin_type"
    t.integer "pin_number"
    t.integer "min"
    t.integer "max"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "transform"
    t.integer "output_pin_number"
    t.index ["device_id", "pin_number"], name: "index_pins_on_device_id_and_pin_number"
    t.index ["device_id"], name: "index_pins_on_device_id"
  end

  create_table "registrations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "auth_token", limit: 6
    t.integer "device_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_token"], name: "index_registrations_on_auth_token"
    t.index ["device_id"], name: "index_registrations_on_device_id"
  end

  create_table "synchronizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_synchronizations_on_device_id"
  end

  create_table "synchronized_pins", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "pin_id"
    t.integer "synchronization_id"
    t.integer "device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["device_id"], name: "index_synchronized_pins_on_device_id"
    t.index ["pin_id"], name: "index_synchronized_pins_on_pin_id"
    t.index ["synchronization_id"], name: "index_synchronized_pins_on_synchronization_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "pins", "devices"
end
