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
  
end
