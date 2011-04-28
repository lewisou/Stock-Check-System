# require 'imagemagick_wrapper'
# require 'gbarcode'
# 
# module Vivax
#   # Extending <tt>ActionView::Base</tt> to support rendering themes
#   module Barcode 
#     include ImageMagickWrapper
# 
#     VALID_BARCODE_OPTIONS = [:encoding_format, :output_format, :width, :height, :scaling_factor, :xoff, :yoff, :margin  ]
#     
#     def safe file_name
#       file_name.gsub(/[\/\" \t\r\n]/, "---")
#     end
#     
#     def barcode(id, options = {:encoding_format => DEFAULT_ENCODING })
#       
#       
#       
#       options.assert_valid_keys(VALID_BARCODE_OPTIONS)
#       output_format = options[:output_format] ? options[:output_format] : DEFAULT_FORMAT
# 
#       id.upcase!
#       eps = "#{::Rails.root.to_s}/public/images/barcodes/#{safe(id)}.eps"
#       out = "#{::Rails.root.to_s}/public/images/barcodes/#{safe(id)}.#{output_format}"
#       
#       #dont generate a barcode again, if already generated
#       unless File.exists?(out)
#         #generate the barcode object with all supplied options
#         options[:encoding_format] = DEFAULT_ENCODING unless options[:encoding_format]
#         bc = Gbarcode.barcode_create(id)
#         bc.width  = options[:width]          if options[:width]
#         bc.height = options[:height]         if options[:height]
#         bc.scalef = options[:scaling_factor] if options[:scaling_factor]
#         bc.xoff   = options[:xoff]           if options[:xoff]
#         bc.yoff   = options[:yoff]           if options[:yoff]
#         bc.margin = options[:margin]         if options[:margin]
#         Gbarcode.barcode_encode(bc, options[:encoding_format])
#         
#         if options[:no_ascii]
#           print_options = Gbarcode::BARCODE_OUT_EPS|Gbarcode::BARCODE_NO_ASCII
#         else
#           print_options = Gbarcode::BARCODE_OUT_EPS
#         end
#         
#         #encode the barcode object in desired format
#         File.open(eps,'wb') do |eps_img| 
#           Gbarcode.barcode_print(bc, eps_img, print_options)
#           eps_img.close
#           convert_to_png(eps, out)
#         end
#         
#         #delete the eps image, no need to accummulate cruft
#         File.delete(eps)
#       end
#       #send the html image tag
#       # image_tag("barcodes/#{id}.#{output_format}")
#       File.new(out)
#     end
# 
#   end
# 
# end