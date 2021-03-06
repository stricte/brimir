// Brimir is a helpdesk system to handle email support requests.
// Copyright (C) 2012-2015 Ivaldi http://ivaldi.nl
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http:gcwww.gnu.org/licenses/>.

jQuery(function() {

  jQuery('[data-assignee-id]').click(function(e) {
    e.preventDefault();

    var elem = jQuery(this);
    var dialog = jQuery('#change-assignee');
    var options = dialog.find('form select');

    /* set ticket id */
    dialog.find('form').attr('action', elem.parents('tr').data('ticket-url'));

    /* select assigned user */
    options.removeAttr('selected');
    options.find('[value="' + elem.data('assignee-id') + '"]').attr('selected', 'selected');

    /* show the dialog */
    dialog.foundation('reveal','open');

  });

  jQuery('[data-set-time-consumed]').click(function(e) {
    e.preventDefault();

    var elem = jQuery(this);
    var dialog = jQuery('#set-time-consumed');

    var daysSelect = dialog.find('form select#ticket_consumed_days');
    var hoursSelect = dialog.find('form select#ticket_consumed_hours');
    var minutesSelect = dialog.find('form select#ticket_consumed_minutes');

    var days = parseInt(elem.data('set-time-consumed').split('-')[0],10);
    var hours = parseInt(elem.data('set-time-consumed').split('-')[1],10);
    var minutes = parseInt(elem.data('set-time-consumed').split('-')[2],10);

    /* set ticket url */
    dialog.find('form').attr('action', elem.parents('tr').data('ticket-url'));

    daysSelect.select2('val', days);
    hoursSelect.select2('val', hours);
    minutesSelect.select2('val', minutes);

    /* show the dialog */
    dialog.foundation('reveal','open');
  });

  jQuery('[data-set-deadline]').click(function(e) {
    e.preventDefault();

    var elem = jQuery(this);
    var dialog = jQuery('#set-deadline');

    var field = dialog.find('input.datetimepicker');

    field.val(elem.data('set-deadline'));

    dialog.find('form').attr('action', elem.parents('tr').data('ticket-url'));

    dialog.foundation('reveal','open');
  });

  jQuery('[data-set-group]').click(function(e) {
    e.preventDefault();

    var elem = jQuery(this);
    var dialog = jQuery('#change_group');

    var groupSelect = dialog.find('form select#ticket_group_id');

    /* set ticket url */
    dialog.find('form').attr('action', elem.parents('tr').data('ticket-url'));

    groupSelect.select2('val', elem.data('set-group'));

    /* show the dialog */
    dialog.foundation('reveal','open');
  });

  jQuery('.select2-tags').select2({tags: [], multiple: true, allowclear: true,width: 'resolve', minimumResultsForSearch: 1});

  jQuery('.select2-create').select2({
    width: 'resolve',
    createSearchChoicePosition: 'bottom',
    createSearchChoice: function(term, data) {
      return { id:term, text:term };
    },
    ajax: {
      url: '/labels.json',
      dataType: 'json',
      data: function (term, page) {
        return {
          q: term
        };
      },
      results: function (data) {
        return { results: data };
      }
    }
  });

  jQuery('a.current.sort-trigger').each(function(){
    var a = jQuery(this);
    a.closest('th').addClass(a.attr("class"));
  });
});
