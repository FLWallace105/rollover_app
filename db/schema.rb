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

ActiveRecord::Schema.define(version: 2021_03_17_021838) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ellie_collects", force: :cascade do |t|
    t.bigint "collect_id", null: false
    t.bigint "collection_id", null: false
    t.bigint "product_id", null: false
    t.string "featured"
    t.string "position"
    t.string "sort_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["collect_id"], name: "index_ellie_collects_on_collect_id"
    t.index ["collection_id"], name: "index_ellie_collects_on_collection_id"
    t.index ["product_id"], name: "index_ellie_collects_on_product_id"
  end

  create_table "ellie_custom_collections", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.string "handle"
    t.string "title"
    t.text "body_html"
    t.datetime "published_at"
    t.string "sort_order"
    t.string "template_suffix"
    t.string "published_scope"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["collection_id"], name: "index_ellie_custom_collections_on_collection_id"
  end

  create_table "ellie_metafields", force: :cascade do |t|
    t.bigint "metafield_id"
    t.bigint "product_id"
    t.string "product_collection"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["metafield_id"], name: "index_ellie_metafields_on_metafield_id"
    t.index ["product_id"], name: "index_ellie_metafields_on_product_id"
  end

  create_table "ellie_products", force: :cascade do |t|
    t.bigint "product_id"
    t.text "body_html"
    t.datetime "created_at"
    t.string "handle"
    t.json "image"
    t.json "images"
    t.json "options"
    t.string "product_type"
    t.datetime "published_at"
    t.string "published_scope"
    t.string "tags"
    t.string "template_suffix"
    t.string "title"
    t.string "metafields_global_title_tag"
    t.string "metafields_global_description_tag"
    t.datetime "updated_at"
    t.text "variants"
    t.string "vendor"
    t.string "admin_graphql_api_id"
    t.index ["product_id"], name: "index_ellie_products_on_product_id"
  end

  create_table "ellie_variants", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.string "sku"
    t.string "title"
    t.integer "inventory_quantity"
    t.bigint "product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_ellie_variants_on_product_id"
    t.index ["variant_id"], name: "index_ellie_variants_on_variant_id"
  end

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

  create_table "selection_sets", force: :cascade do |t|
    t.integer "selection_set_type", default: 0
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean "ignore_dates_use_nulls", default: false
    t.boolean "allow_ellie_picks_in_selection_set", default: false
    t.boolean "use_size_breaks", default: false
    t.boolean "use_gloves_in_size_breaks", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
