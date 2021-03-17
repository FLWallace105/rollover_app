class InventorySize < ApplicationRecord
    enum product_size: [:XS, :S, :M, :L, :XL]
    enum product_type: { "leggings" => 0, "tops" =>1, "sports-bra" => 2, "sports-jacket" => 3, "gloves" => 4}



    validates :product_size, inclusion: { in: %w(XS S M L XL),
        message: "%{value} is not a valid size" }
    
    validates :product_type, inclusion: { in: %w(sports-bra sports-jacket tops leggings gloves)}
    message: "%{value} is not a valid product_type" }
    #should take from model SizeBreak

end
