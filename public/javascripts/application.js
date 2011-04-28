// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.noConflict();

jQuery(function($) {
	$('input.loader').each(function(){
		$(this).next().hide();
	});

	$('input.loader').click(function() {
		$(this).hide();
		$(this).next().fadeToggle();
		return true;
	});
})