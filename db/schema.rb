# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_12_235235) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "orders", force: :cascade do |t|
    t.integer "order_id"
    t.integer "customer_id"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "product_collection"
    t.string "leggings"
    t.string "tops"
    t.string "sports_bra"
    t.string "sports_jacket"
    t.string "gloves"
    t.boolean "is_prepaid", default: false
    t.string "status"
    t.decimal "total_line_items_price", precision: 10, scale: 2
    t.datetime "scheduled_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "line_items"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["order_id"], name: "index_orders_on_order_id"
  end

  create_table "sub_collection_sizes", force: :cascade do |t|
    t.bigint "subscription_id"
    t.string "product_collection"
    t.string "gloves"
    t.string "leggings"
    t.string "tops"
    t.string "sports_bra"
    t.string "sports_jacket"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subscription_id"], name: "index_sub_collection_sizes_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "subscription_id"
    t.bigint "address_id"
    t.bigint "customer_id"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "next_charge_scheduled_at"
    t.string "product_title"
    t.string "variant_title"
    t.decimal "price", precision: 10, scale: 2
    t.integer "quantity"
    t.string "status"
    t.bigint "recharge_product_id"
    t.bigint "shopify_product_id"
    t.bigint "shopify_variant_id"
    t.string "sku"
    t.string "order_interval_unit"
    t.string "order_interval_frequency"
    t.string "charge_interval_frequency"
    t.integer "order_day_of_month"
    t.integer "order_day_of_week"
    t.jsonb "properties"
    t.integer "expire_after_specific_number_of_charges"
    t.integer "has_queued_charges"
    t.boolean "is_prepaid", default: false
    t.boolean "is_skippable", default: false
    t.boolean "is_swappable", default: false
    t.integer "max_retries_reached"
    t.boolean "sku_override", default: false
    t.string "product_collection"
    t.index ["subscription_id"], name: "index_subscriptions_on_subscription_id"
  end

end
