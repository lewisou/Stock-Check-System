require 'ext/tag_table'
require 'ext/spreadsheet'
require 'pp'

class ReportsController < Adm::BaseController
  before_filter { @nav = :tag }
  layout 'tags'

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
        render :layout => "tags"
      }

      format.xls {
        @tags = @search.all
        book = Spreadsheet::Workbook.new

        data = book.generate_xls(
        "Variance Count 1 VS 2", @tags,        
        ['Tag #', 'Desc.', 'Warehouse', 'Shelf Loc', 'Count 1', 'Count 2', 'Differ', 'Value 1', 'Value 2', 'Differ', 'Count 3'],
        [:id, [:inventory, :item, :description], [:inventory, :location, :code], :sloc, :count_1, :count_2, :count_differ, :value_1, :value_2, :value_differ, :count_3]
        )

        send_data data, :filename => "Variance Count 1 VS 2.xls", :disposition => 'attachment'
      }
    end
  end

  def final_result
    @search = Tag.in_check(curr_check.id).where(:count_1.gte % 0 & :count_2.gte % 0).search(params[:search])
    
    respond_to do |format|
      format.html { @tags = @search.paginate(:page => params[:page]) }
      
      format.xls {
        @tags = @search.all
        book = Spreadsheet::Workbook.new
        # data = book.generate_xls("Final Report", @tags, %w{Tag Location Item Description Counted Cost Value}, [:id, [:inventory, :location, :code], [:inventory, :item, :code], [:inventory, :item, :description], :final_count, [:inventory, :item, :cost], :counted_value])
        send_data book.render_final_report(@tags), :filename => "Final Report.xls", :disposition => 'attachment'
      }
    end

  end
  
  def final_frozen
    @check = Check.find(params[:id])
    
    @search = Inventory.in_check(@check.id).search(params[:search])
    @nav = :archive

    respond_to do |format|
      format.html { @inventories = @search.paginate(:page => params[:page]) }
      
      format.xls {
        @inventories = @search.all
        book = Spreadsheet::Workbook.new
        send_data book.render_inventories(@inventories, "Final Report with Frozen QTY"), :filename => "Final Report with Frozen QTY.xls", :disposition => 'attachment'
      }
    end

  end


  def count_frozen
    @c_i = (params[:count] || "1").to_i
    @c_s = "count_#{@c_i.to_s}".to_sym

    @search = Inventory.in_check(curr_check.id).onsite_s.search(params[:search])

    respond_to do |format|
      format.html { @inventories = @search.paginate(:page => params[:page]) }
      format.xls {
        @inventories = @search.all
        book = Spreadsheet::Workbook.new
        data = book.generate_xls("Count Result VS Frozen", @inventories, %w{Location Item Description FrozenCost Cost FrozenQTY counted_1_qty counted_2_qty result_qty counted_1_value_differ counted_2_value_differ result_value_differ},
        [[:location, :code],
        [:item, :code], 
        [:item, :description],
        [:item, :al_cost], [:item, :cost], 
        :quantity, :counted_1_qty, :counted_2_qty, :result_qty, :counted_1_value_differ, :counted_2_value_differ, :result_value_differ
        ])
        send_data data, :filename => "Count Result VS Frozen.xls", :disposition => 'attachment'
      }
    end
  end
  
end
