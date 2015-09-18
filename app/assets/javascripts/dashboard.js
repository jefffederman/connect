$(function() {
  $(".webhook button").
    show().
    click(function() {
      $(this).
        hide().
        siblings(".webhook-value").
        show().
        find("input").
        select();
    });

  $(".webhook-value").hide();
});
