(function() {

  $(document).ready(function() {
    $.timeago.settings.allowFuture = true;
    $('.timeago').timeago();
    return $('.search-form').submit(function() {
      var loc, q;
      q = $.trim($(this).find('input[name="q"]').val());
      loc = $.trim($(this).find('input[name="loc"]').val());
      if (!(q.length || loc.length)) return false;
      if (/^\w+$/.test(q)) {
        if (loc && /^\w+$/.test(loc)) {
          $(this).attr('action', '/search/' + q + '_in_' + loc + '.html');
        } else {
          $(this).attr('action', '/search/' + q + '.html');
        }
      } else {
        if (loc && /^\w+$/.test(loc)) {
          $(this).attr('action', '/search/in_' + loc + '.html');
        }
      }
      return true;
    });
  });

}).call(this);
