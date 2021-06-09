class Loaders
  def self.load_allocation_size_types
    AllocationSizeType.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('allocation_size_types')
    allocation_size_type_attributes = []
    CSV.foreach('csvs/allocation_size_types.csv', :encoding => 'ISO8859-1:utf-8', :headers => true) do |row|
      puts row.inspect
      allocation_size_type_attributes << {
        collection_name: row['collection_name'],
        collection_id: row['collection_id'],
        collection_size_type: row['collection_size_type']
      }
    end
    AllocationSizeType.import(allocation_size_type_attributes)
    puts "all done"
  end

  def self.load_allocation_matching_products
    AllocationMatchingProduct.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('allocation_matching_products')
    allocation_matching_product_attributes = []
    CSV.foreach('csvs/allocation_matching_products_production.csv', :encoding => 'ISO8859-1:utf-8', :headers => true) do |row|
      puts row.inspect
      allocation_matching_product_attributes << {
        product_title: row['product_title'],
        incoming_product_id: row['incoming_product_id'],
        prod_type: row['prod_type'],
        outgoing_product_id: row['outgoing_product_id']
      }
    end
    AllocationMatchingProduct.import(allocation_matching_product_attributes)
    puts "Done with loading allocation_matching_products table"
  end
end