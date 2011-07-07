class Attachment < ActiveRecord::Base
  has_attached_file :data

  # def is_group_xls?
  #   first_row_eq ['Name', 'ItemType', 'ItemTypeShort', 'ExpenseAcct', 'AssetAcct', 'COGSAcct', 'IncomeAcct', 'PrimaryUOM', 'PurchaseUOM', 'PurchaseFactor', 'SaleUOM', 'SaleFactor', 'UseUOM', 'UseFactor', 'IsPurchased', 'IsSold', 'IsUsed', 'IsActive']
  # end
  # 
  # def is_location_xls?
  #   first_row_eq ['Location', 'Address 1', 'Address 2', 'Address 3', 'City', 'State', 'Zip', 'Active', 'Available']
  # end
  # 
  # def is_item_xls?
  #   first_row_eq ['Item', 'SalesDesc', 'PurchaseDesc', 'ItemType', 'ItemTypeShort', 'QBType', 'MakeUseTypeName', 'MakeUseTypeShort', 'PrimaryUOM', 'PurchUOM', 'PurchaseFactor', 'SalesUOM', 'SaleFactor', 'UseUOM', 'UseFactor', 'QuantityOnHand', 'ReorderPoint', 'ReorderAmount', 'PurchaseCost', 'LastPurchaseCost', 'AverageCost', 'Price', 'BinName', 'LocLocation', 'COGSAccount', 'SalesAccount', 'AssetAccount', 'ExpenseAccount', 'SalesTaxCode', 'PriceLevelName', 'Weight', 'Manufacturer', 'MftgPartNumber', 'UPC', 'IsActive', 'VendorPartNo', 'HasLotSer', 'Proxy', 'ImageFile', 'ItemCust1', 'ItemCust2', 'ItemCust3', 'ItemCust4', 'ItemCust5', 'ItemCust6', 'ItemCust7', 'ItemCust8', 'ItemCust9', 'ItemCust10', 'ItemCust11', 'ItemCust12', 'ItemCust13', 'ItemCust14', 'ItemCust15', 'ItemCust16', 'ItemCust17', 'ItemCust18', 'ItemCust19', 'ItemCust20', 'ItemCust21', 'ItemCust22', 'ItemCust23', 'ItemCust24', 'ItemCust25', 'ItemCust26', 'ItemCust27', 'ItemCust28', 'ItemCust29', 'ItemCust30', 'TimeCreated', 'TimeModified', 'Vendor', 'MaxQty', 'Volume', 'FullItemName', 'ID']
  # end
  # 
  # def is_inventory_xls?
  #   first_row_eq ['Item', 'Location', 'UOM', 'PurchaseDesc', 'SalesDesc', 'AverageCost', 'IsActive', 'Qty', 'Committed', 'Allocated', 'InTransit', 'RMA', 'WIP', 'AvailableToSell', 'AvailableToShip', 'OnHand', 'Owned', 'Value', 'ItemCust1', 'ItemCust2', 'ItemCust3', 'ItemCust4', 'ItemCust5', 'ItemCust6', 'ItemCust7', 'ItemCust8', 'ItemCust9', 'ItemCust10', 'ItemCust11', 'ItemCust12', 'ItemCust13', 'ItemCust14', 'ItemCust15', 'AvailablePurchaseValue', 'PurchaseCost', 'OnHandPurchaseValue']
  # end
  # 
end

# == Schema Information
#
# Table name: attachments
#
#  id                :integer         not null, primary key
#  data_file_name    :string(255)
#  data_content_type :string(255)
#  data_file_size    :integer
#  data_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

