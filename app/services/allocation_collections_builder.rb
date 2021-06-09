class AllocationCollectionsBuilder
  def self.call
    AllocationCollection.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('allocation_productions')

    alternate_products = AlternateProduct.all.where("product_collection ilike '%5%'")

    allocation_collection_attrs = []
    alternate_products.each_with_index do |alternate_product, index|
      allocation_collection_attrs << {
        name: /.+?(?=-)/.match(alternate_product.product_collection).to_a[0].to_s.strip,
        collection_id: index + 1,
        product_id: alternate_product.product_id
      }
    end

    AllocationCollection.import allocation_collection_attrs
  end
end
