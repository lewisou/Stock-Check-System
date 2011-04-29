// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

(function($) {
	
	// $('input.once').each(function(){
	// 	$(this).next().hide();
	// 
	// 	$(this).bind({
	// 		click: function() {
	// 			$(this).unbind('click')
	// 			// $(this).fadeOut();
	// 			$(this).next().fadeIn();
	// 		}
	// 	});
	// });

	$('.once').live('click.scs', function(e) {
		var link = $(this);

		if (link.html() != "Processing..." && (link.attr('rails-confirm') == undefined || link.attr('rails-confirm') == 'yes')) {
			$('a[data-confirm], a[data-method], a[data-remote]').die("click.rails");
			$('form input[type=submit], form input[type=image], form button[type=submit], form button:not([type])').die('click.rails');			

			$('.once').die('click.scs');
			$('.once').bind('click', function(){
				return false;
			});
			
			if (link.is("a")) {
				link.hide();
				// link.text("Processing...")
			} else {
				link.hide();
				// link.attr("disabled", "disabled")
				// link.val("Processing...")
			}
			
			link.next().fadeIn();
			return true
		}
		return false
	});


})( jQuery );