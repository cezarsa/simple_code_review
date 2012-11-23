(function ($) {
    var height = 0,
        panels = $('#repositories').find('.panel');
    panels.each(function () {
        if ($(this).outerHeight() > height) {
            height = $(this).outerHeight();
        }
    }).height(height);
})(jQuery);
