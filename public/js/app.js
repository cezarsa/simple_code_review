(function ($) {
    var height = 0,
        panels = $('#repositories').find('.panel');
    panels.each(function () {
        if ($(this).outerHeight() > height) {
            height = $(this).outerHeight();
        }
    }).height(height);

    $('.frm-delete').submit(function (e) {
        if (confirm('Are you sure?')) {
            return true;
        }
        e.preventDefault();
    });
})(jQuery);
