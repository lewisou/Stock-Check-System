require "prawn/measurement_extensions"
# require 'ext/prawn'
# require 'ext/barcode'
# require "open-uri"

module Prawn

  class Document
    # include Vivax::Barcode
    
    TAG_TABLE_WIDTH = 8.9.cm 
    PADDING = [0.5.cm, 0.5.cm, 0.48.cm, 0.5.cm] #top right buttom left
    
    def self.generate_tags tags
      #, tag_colors = ['db4653', '009f6e', '418bb9', 'b89466']
      pdf = Prawn::Document.new(
        :page_layout => :portrait,
        :left_margin => 0, #1.3.cm,    # different
        :right_margin => 0, #1.3.cm,    # units
        :top_margin => 0.05.cm, #0.7.cm,    # work
        :bottom_margin => 0, #0.7.cm, # well
        # :font_size => 11,
        # :font => "Arial",
        # :page_size => 'A3',
        :page_size   => [35.56.cm, 21.59.cm]
        # :page_size => 'A4'
        ) do

        font_size 11
        # font "Courier"

        tags.each_with_index do |tag, index|
          start_new_page if index % 3 == 0 && index != 0

          tables = []
          # tag_colors.each_with_index do |tag_color, index_2|
          4.times do 
            tables << make_tag_table(tag)
            # table.draw
            # ((index_2 + 1) % tag_colors.size) == 0
          end

          table([tables], :width => TAG_TABLE_WIDTH * 4, :cell_style => {:borders => [], :padding => 0})
          # puts "#{index} finished"
        end
      end

      pdf
    end

    def make_tag_sub_table data, options={}
      make_table([data], :width => TAG_TABLE_WIDTH, :column_widths => [TAG_TABLE_WIDTH / data.size] * data.size, :cell_style => {:borders => [], :padding => 0}.merge(options))
      # , :border_color => tag_color, :text_color => tag_color})
    end
    
    def image_wrapper val
      Prawn::ImageWrapper.new(barcode(val), [val.size * 0.5.cm, TAG_TABLE_WIDTH].min, 1.cm)
    end
    
    def make_tag_table(tag)
      # Prawn::ImageWrapper.new(barcode(tag.id.to_s), TAG_TABLE_WIDTH / 3, TAG_TABLE_WIDTH / 10
      item = tag.inventory.item.try(:code) || "No content"
      description = (tag.inventory.item.try(:description) || "No descrption")[0, 30] + "..."
      data = [
        # [make_tag_sub_table(["\n#{tag.id}", image_wrapper(tag.id.to_s)], tag_color)],
        [make_tag_sub_table(["#{tag.id}", " "], :font_style => :bold)],
        ["#{item} "],
        ["#{description} "],
        ["#{tag.sloc} "], #image_wrapper(item)
        [make_tag_sub_table(["#{tag.inventory.location.code} ", "#{tag.created_at.to_date} ", " "])]
      ]

      t = make_table(data) do |table|
        table.width = TAG_TABLE_WIDTH
        table.column_widths = [TAG_TABLE_WIDTH]

        table.cells.style(:padding => PADDING, :borders => [])
        # :border_color => tag_color, :text_color => tag_color, 
      end

      t
    end
  end
  
end
