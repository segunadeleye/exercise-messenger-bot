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

ActiveRecord::Schema.define(version: 2018_05_07_164036) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exercises", force: :cascade do |t|
    t.string "name"
    t.string "picture"
    t.string "video"
    t.text "purpose"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "performed_routines", force: :cascade do |t|
    t.bigint "workout_session_id", null: false
    t.bigint "routine_id", null: false
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["routine_id"], name: "index_performed_routines_on_routine_id"
    t.index ["status"], name: "index_performed_routines_on_status"
    t.index ["workout_session_id"], name: "index_performed_routines_on_workout_session_id"
  end

  create_table "routines", force: :cascade do |t|
    t.bigint "workout_id"
    t.bigint "exercise_id"
    t.integer "set"
    t.integer "repetition"
    t.integer "preparation"
    t.integer "start"
    t.integer "hold"
    t.integer "release"
    t.integer "pause"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_routines_on_exercise_id"
    t.index ["workout_id"], name: "index_routines_on_workout_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "sender_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sender_id"], name: "index_users_on_sender_id"
  end

  create_table "workout_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "workout_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_workout_sessions_on_status"
    t.index ["user_id"], name: "index_workout_sessions_on_user_id"
    t.index ["workout_id"], name: "index_workout_sessions_on_workout_id"
  end

  create_table "workouts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
