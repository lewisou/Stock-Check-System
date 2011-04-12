require 'prawn'
# encoding: utf-8   

# image.rb: Image table cells.
#
# Copyright April 2011, Lewis Zhou. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  
  class ImageWrapper
    attr_accessor :file, :image_width, :image_height
    
    def initialize file, wid, hei
      @file = file
      @image_width = wid
      @image_height = hei
    end
  end
  
  class Table
    class Cell

      # A Cell that contains image. Has some limited options to set
      # size, and style.
      #
      class Image < Cell

        ImageOptions = [:image_width, :image_height, :align, :valign,
          :rotate, :rotate_around, :leading,
          :overflow]

        ImageOptions.each do |option|
          define_method("#{option}=") { |v| @image_options[option] = v }
          define_method(option) { @image_options[option] }
        end
        
        attr_writer :text_color

        def initialize(pdf, point, options={})
          @image_options = {}
          super
        end

        # Returns the width of this text with no wrapping. This will be far off
        # from the final width if the text is long.
        #
        def natural_content_width
          [image_width, @pdf.bounds.width].min
        end

        # Returns the natural height of this block of text, wrapped to the
        # preset width.
        #
        def natural_content_height
          image_height
        end

        # Draws the image content into its bounding box.
        #
        def draw_content
          # with_font do
          @pdf.move_down((@pdf.font.line_gap + @pdf.font.descender)/2)
          @pdf.image(@content.file, :at => [0, @pdf.cursor], :width => @content.image_width, :height => @content.image_height)
            # with_text_color do
            #   text_box(:width => content_width + FPTolerance, 
            #            :height => content_height + FPTolerance,
            #            :at => [0, @pdf.cursor]).render
            # end
          # end
        end

        protected

        def set_width_constraints
          # Sets a reasonable minimum width. If the cell has any content, make
          # sure we have enough width to be at least one character wide. This is
          # a bit of a hack, but it should work well enough.
          min_content_width = [natural_content_width].min
          @min_width ||= padding_left + padding_right + min_content_width
          super
        end

        # def text_box(extra_options={})
        #   if @text_options[:inline_format]
        #     options = @text_options.dup
        #     options.delete(:inline_format)
        # 
        #     array = ::Prawn::Text::Formatted::Parser.to_array(@content)
        #     ::Prawn::Text::Formatted::Box.new(array,
        #       options.merge(extra_options).merge(:document => @pdf))
        #   else
        #     ::Prawn::Text::Box.new(@content, @text_options.merge(extra_options).
        #        merge(:document => @pdf))
        #   end
        # end

        # Returns the width of +text+ under the given text options.
        #
        # def styled_width_of(text)
        #   with_font do
        #     options = {}
        #     options[:size] = @text_options[:size] if @text_options[:size]
        # 
        #     @pdf.font.compute_width_of(text, options)
        #   end
        # end

      end


      # copy from git repo and add two lines
      # when File
      #   Cell::Image.new(pdf, at, options)
      #   
      def self.make(pdf, content, options={})
        at = options.delete(:at) || [0, pdf.cursor]
        content = content.to_s if content.nil? || content.kind_of?(Numeric) ||
          content.kind_of?(Date)
        
        if content.is_a?(Hash)
          options.update(content)
          content = options[:content]
        else
          options[:content] = content
        end

        case content
        when ImageWrapper
          Cell::Image.new(pdf, at, options.merge(:image_width => content.image_width, :image_height => content.image_height))
        when Prawn::Table::Cell
          content
        when String
          Cell::Text.new(pdf, at, options)
        when Prawn::Table
          Cell::Subtable.new(pdf, at, options)
        when Array
          subtable = Prawn::Table.new(options[:content], pdf, {})
          Cell::Subtable.new(pdf, at, options.merge(:content => subtable))
        else
          # TODO: other types of content
          raise ArgumentError, "Content type not recognized: #{content.inspect}"
        end
      end
      
    end
  end
end
