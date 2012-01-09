require 'ext/tag_table'
require 'ext/spreadsheet'
require 'pp'

class ReportsController < Adm::BaseController
  before_filter { @nav = params[:nav].blank? ? :tag : params[:nav].to_sym }
  layout "application"

  before_filter {
    @check = Check.find(params[:check_id])
  }

  def inventories
    @search = Inventory.in_check(@check.id).report_valid.search(params[:search])

    respond_to do |format|
      format.html { 
        @inventories = @search.paginate(:page => params[:page])
      }
      format.xls {
        @inventories = @search.all
        book = Spreadsheet::Workbook.new
        
        data = book.generate_xls(
        "Final Summary by value", @inventories,        
        %w{Warehouse Part# Desc. Cost Count_1_QTY Count_2_QTY RemoteWS_QTY Frozen_QTY Frozen_Val. Final_SCS_QTY Final_SCS_Val. Adjustment_to_QTY_frozen Adjustment_Value},
        [[:location, :code], 
          [:item, :code],
          [:item, :description],
          [:item, :cost],
          :counted_1_qty,
          :counted_2_qty,
          :inputed_qty,
          :quantity,
          :frozen_value,
          :result_qty,
          :result_value,
          :ao_adj,
          :ao_adj_value],
          :summary => [["Net adjustment Value", @check.ao_adj_value],
          ["Sum of up and down",  @check.ao_adj_abs_value],
          ["Total Frozen Value", @check.frozen_value],
          ["Total SCS Value (Remote & Onsite)", @check.final_value]]
        )
        
        send_data data, :filename => "Check_#{@check.description}_summary_by_value.xls", :disposition => 'attachment'
      }
    end
  end

  def tags
    @check = Check.find(params[:check_id])
    @search = Tag.in_check(@check.id).countable.search(params[:search])

    respond_to do |format|
      format.html { @tags = @search.paginate(:page => params[:page]) }
      format.xls {
        @tags = @search.all
        book = Spreadsheet::Workbook.new
        # data = book.generate_xls("Final Report", @tags, %w{Tag Location Item Description Counted Cost Value}, [:id, [:inventory, :location, :code], [:inventory, :item, :code], [:inventory, :item, :description], :final_count, [:inventory, :item, :cost], :counted_value])

        data = book.generate_xls(
        "Counts by location", @tags, 
        %w{Ticket_No Warehouse Shelf_Location Part_Number Description Count_1 Count_2 Count_3 Audit Final}, 
        [:id, 
          [:inventory, :location, :code],
          :sloc,
          [:inventory, :item, :code], 
          [:inventory, :item, :description],
          :count_1,
          :count_2,
          :count_3,
          :audit,
          :final_count
        ]
        )

        send_data data, :filename => "Check_#{@check.description}_counts_by_location.xls", :disposition => 'attachment'
      }
    end
  end

  def count_varience

    @tole = {:tole_quantity => (params[:tole_quantity] || curr_check.credit_q), :tole_value => (params[:tole_value] || curr_check.credit_v)}

    @search = Tag.in_check(curr_check.id).finish(1).finish(2)\
    .tole_q_or_v(@tole[:tole_quantity], @tole[:tole_value]).search(params[:search])\
    # .search(params[:search])
    # ({"tolerance_q" => curr_check.credit_q, "tolerance_v" => curr_check.credit_v}).merge((params[:search] || {}).delete_if {|key, value| value.blank? })
    # )

    respond_to do |format|
      format.html { 
        @tags = @search.paginate(:page => params[:page])
      }

      format.xls {
        @tags = @search.all
        book = Spreadsheet::Workbook.new

        data = book.generate_xls(
        "Variance Count 1 VS 2", @tags,        
        ['Tag #', 'Item #', 'Desc.', 'Warehouse', 'Shelf Loc', 'Count 1', 'Count 2', 'Differ', 'Value 1', 'Value 2', 'Differ', 'Count 3'],
        [:id, [:inventory, :item, :code], [:inventory, :item, :description], [:inventory, :location, :code], :sloc, :count_1, :count_2, :count_differ, :value_1, :value_2, :value_differ, :count_3]
        )

        send_data data, :filename => "Variance Count 1 VS 2.xls", :disposition => 'attachment'
      }
    end
  end

  def count_frozen
    @c_i = (params[:count] || "1").to_i
    @c_s = "count_#{@c_i.to_s}".to_sym

    @search = Inventory.in_check(curr_check.id).onsite_s.search(params[:search])

    respond_to do |format|
      format.html { 
        @inventories = @search.paginate(:page => params[:page])
      }
      format.xls {
        @inventories = @search.all
        book = Spreadsheet::Workbook.new
        data = book.generate_xls("Count Result VS Frozen", @inventories, %w{Location Item Description FrozenCost Cost FrozenQTY CountedOneQty CountedTwoQty ResultQty FrozenValue CountedOneValueDiffer CountedTwoValueDiffer ResultValueDiffer},
        [[:location, :code],
        [:item, :code],
        [:item, :description],
        [:item, :al_cost], [:item, :cost],
        :quantity, :counted_1_qty, :counted_2_qty, :result_qty, :frozen_value, :counted_1_value_differ, :counted_2_value_differ, :result_value_differ
        ])
        send_data data, :filename => "Count Result VS Frozen.xls", :disposition => 'attachment'
      }
    end
  end

  def remote_warehouse_by_item
    @search = @check.items.remoted_s.search(params[:search])
    @inventories = Inventory.in_check(@check.id).remote_s.order("item_id ASC, location_id ASC")

    @frozen_qty = @inventories.sum(:quantity) || 0
    @frozen_value = @inventories.sum(:frozen_value) || 0
    @inputed_qty = @inventories.sum(:result_qty) || 0
    @inputed_value = @inventories.sum(:result_value) || 0
    
    respond_to do |format|
      format.html {
        @items = @search.paginate(:page => params[:page])
      }
      
      format.xls {
        @items = @check.items.remoted_s
        
        book = Spreadsheet::Workbook.new
        data = book.advanced_generate_xls("Remote Tickets by Item", [@items, @inventories],
        [%w{Item# Description Cost FrozenQTY InputedQty FrozenValue InputedValue},
        %w{Item# Warehouse FrozenQTY InputedQty FrozenValue InputedValue}],
        [
        [:code,
        :description,
        :cost,
        [:item_info, :sum_remote_frozen_qty],
        [:item_info, :sum_remote_result_qty],
        [:item_info, :sum_remote_frozen_value],
        [:item_info, :sum_remote_result_value]],
        [[:item, :code],
        [:location, :code],
        :quantity,
        :result_qty,
        :frozen_value,
        :result_value,
        ]
        ],
        :summary => [
        ["Total Frozen Qty", @frozen_qty],
        ["Total Inputed Qty", @inputed_qty],
        ["Total Frozen Value", @frozen_value],
        ["Total Inputed Value", @inputed_value]
        ])

        send_data data, :filename => "Remote Tickets by Item.xls", :disposition => 'attachment'
      }
    end
    
  end

  def remote_warehouse_by_warehouse
    @search = @check.locations.not_tagable.search(params[:search])
    @inventories = Inventory.in_check(@check.id).remote_s.order("location_id ASC, item_id ASC")

    @frozen_qty = @inventories.sum(:quantity) || 0
    @frozen_value = @inventories.sum(:frozen_value) || 0

    @inputed_qty = @inventories.sum(:result_qty) || 0
    @inputed_value = @inventories.sum(:result_value) || 0

    respond_to do |format|
      format.html {
        @locations = @search.paginate(:page => params[:page])
      }

      format.xls {
        @locations = @search.all

        book = Spreadsheet::Workbook.new
        data = book.advanced_generate_xls("Remote Tickets by Warehouse", [@locations, @inventories],
        [%w{Warehouse FrozenQTY InputedQty FrozenValue InputedValue}, %w{Warehouse Item FrozenQty InputedQty FrozenValue InputedValue}],
        [
        [:code,
        [:location_info, :sum_frozen_qty],
        [:location_info, :sum_result_qty],
        [:location_info, :sum_frozen_value],
        [:location_info, :sum_result_value]
        ],
        [[:location, :code],
          [:item, :code],
          :quantity,
          :inputed_qty,
          :frozen_value,
          :result_value]
        ],
        :summary => [
        ["Total Frozen Qty", @frozen_qty],
        ["Total Inputed Qty", @inputed_qty],
        ["Total Frozen Value", @frozen_value],
        ["Total Inputed Value", @inputed_value]
        ])

        send_data data, :filename => "Remote Tickets by Warehouse.xls", :disposition => 'attachment'
      }
    end
  end

end
