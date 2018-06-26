var is_touch_device = !!('ontouchstart' in window) || !!('msmaxtouchpoints' in window.navigator);

$(function() {

  // Elements

  var $window = $(window);
  var html_body = $('html,body');

  // Touch devices class

  if (is_touch_device) {
    // For being able to use `body.touch-device` in CSS
    $('body').addClass("touch-device");
  }

  // Lazy load

  $('img.lazy').lazyload({
    data_attribute: 'src',
    effect: 'fadeIn'
  });

});

