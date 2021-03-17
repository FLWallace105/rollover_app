class CreateShopifyResources < ActiveRecord::Migration[6.1]
  def change
    create_table :ellie_products do |t|
      t.bigint :product_id
      t.text :body_html
      t.timestamp :created_at
      t.string :handle
      t.json :image
      t.json :images
      t.json :options
      t.string :product_type
      t.timestamp :published_at
      t.string :published_scope
      t.string :tags
      t.string :template_suffix
      t.string :title
      t.string :metafields_global_title_tag
      t.string :metafields_global_description_tag
      t.timestamp :updated_at
      t.text :variants
      t.string :vendor
      t.string :admin_graphql_api_id
    end
    add_index :ellie_products, :product_id

    create_table :ellie_metafields do |t|
      t.bigint :metafield_id
      t.bigint :product_id
      t.string :product_collection
      t.timestamps
    end
    add_index :ellie_metafields, :metafield_id
    add_index :ellie_metafields, :product_id

    create_table :ellie_variants do |t|
      t.bigint :variant_id, null: false
      t.string :sku
      t.string :title
      t.integer :inventory_quantity
      t.bigint :product_id, null: false
      t.timestamps
    end
    add_index :ellie_variants, :variant_id
    add_index :ellie_variants, :product_id

    create_table :ellie_custom_collections do |t|
      t.bigint :collection_id, null: false
      t.string :handle
      t.string :title
      t.text :body_html
      t.timestamp :published_at
      t.string :sort_order
      t.string :template_suffix
      t.string :published_scope
      t.timestamps
    end
    add_index :ellie_custom_collections, :collection_id

    create_table :ellie_collects do |t|
      t.bigint :collect_id, null: false
      t.bigint :collection_id, null: false
      t.bigint :product_id, null: false
      t.string :featured
      t.string :position
      t.string :sort_value
      t.timestamps
    end
    add_index :ellie_collects, :collect_id
    add_index :ellie_collects, :collection_id
    add_index :ellie_collects, :product_id
  end
end
