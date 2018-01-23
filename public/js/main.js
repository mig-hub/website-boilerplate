var is_touch_device = !!('ontouchstart' in window) || !!('msmaxtouchpoints' in window.navigator);

$(function() {

  if (is_touch_device) {
    // For being able to use `body.touch-device` in CSS
    $('body').addClass("touch-device");
  }

  $('img.lazy').lazyload({
    data_attribute: 'src',
    effect: 'fadeIn'
  });

});

