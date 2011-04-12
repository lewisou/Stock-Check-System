require "prawn/measurement_extensions"
require 'ext/prawn'
require 'ext/barcode'
# require "open-uri"

module Prawn

  class Document
    include Vivax::Barcode
    
    TAG_TABLE_WIDTH = 180
    
    def self.generate_tags tags, tag_colors = ['db4653', '009f6e', '418bb9', 'b89466']
      pdf = Prawn::Document.new(
        :page_layout => :portrait,
        :left_margin => 1.mm,    # different
        :right_margin => 1.cm,    # units
        :top_margin => 1.mm,    # work
        :bottom_margin => 0.01.m, # well
        :page_size => 'A3') do
        
        tags.each_with_index do |tag, index|
          start_new_page if (index + 1) % 3 == 0
          
          tables = []
          tag_colors.each_with_index do |tag_color, index_2|
            tables << make_tag_table(tag, tag_color)
            # table.draw
            # ((index_2 + 1) % tag_colors.size) == 0
          end
          
          table([tables], :cell_style => {:borders => []})
        end
      end
      
      pdf
    end
    
    def make_tag_sub_table data, tag_color
      make_table([data], :width => TAG_TABLE_WIDTH, :column_widths => [TAG_TABLE_WIDTH / 3] * 3, :cell_style => {:borders => [], :border_color => tag_color, :text_color => tag_color})
    end
    
    def make_tag_table(tag, tag_color)
      data = [
        ["Tag #"],
        [Prawn::ImageWrapper.new(barcode(tag.id.to_s), TAG_TABLE_WIDTH / 8, TAG_TABLE_WIDTH / 2)],
        [tag.id],
        ["Item #"],
        [tag.part.try(:code) || "No content"],
        ["Item #"],
        [tag.part.try(:code) || "No content"],
        ["Description"],
        [tag.part.try(:description) || "No descrption"],
        [make_tag_sub_table(["Location", "Date", "Count"], tag_color)],
        [make_tag_sub_table(["AAAAA-BB", "2001-12-02", ""], tag_color)]
      ]
      
      
      t = make_table(data) do |table|
        table.width = TAG_TABLE_WIDTH
        table.column_widths = [TAG_TABLE_WIDTH]
        
        # table.cells.style(:padding => 0, :borders => [:bottom, :left], :border_color => '0022aa', :border_width => 1)
        # table.cells.style(:borders => [])
        # table.cells[1, 0].style(:borders => [])
        # table.cells[2, 0].style(:borders => [])
        # [2, 4, 6].each {|i| table.cells[i, 0].style(:borders => [:top])}


        table.cells.style(:border_color => tag_color, :text_color => tag_color)
      end
    
      t
    end
  end
  
end
