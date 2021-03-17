class InventorySize < ApplicationRecord
    validates :product_size, inclusion: { in: %w(XS S M L XL),
        message: "%{value} is not a valid size" }
    
    validates :product_type, inclusion: { in: %w(sports-bra sports-jacket tops leggings gloves)}
    message: "%{value} is not a valid product_type" }
    #should take from model SizeBreak

end
