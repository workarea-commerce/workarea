%Q{
  <div class="wysiwyg__toolbar" id="<%= id %>">
      <div class='wysiwyg__toolbar-dropdown'>
        <button type='button' class='wysiwyg__toolbar-dropdown-button'>
          <%= I18n.t('workarea.admin.js.wysiwyg.style') %>
          #{ inline_svg_tag('workarea/admin/icons/expand_more.svg', class: 'svg-icon svg-icon--small', title: I18n.t('workarea.admin.js.wysiwyg.italic')) }
        </button>
        <div class='wysiwyg__toolbar-dropdown-content'>
          <a class='wysiwyg__toolbar-dropdown-option' data-wysihtml-command='formatBlock' data-wysihtml-command-value='h2'>
            <span><%= I18n.t('workarea.admin.js.wysiwyg.heading') %></span>
          </a>
          <a class='wysiwyg__toolbar-dropdown-option' data-wysihtml-command='formatBlock' data-wysihtml-command-value='h3'>
            <span><%= I18n.t('workarea.admin.js.wysiwyg.sub_heading') %></span>
          </a>
          <a class='wysiwyg__toolbar-dropdown-option' data-wysihtml-command='formatBlock' data-wysihtml-command-blank-value='true'>
            <span><%= I18n.t('workarea.admin.js.wysiwyg.plain_text') %></span>
          </a>
        </div>
      </div>

      <a class='wysiwyg__toolbar-button' data-wysihtml-command='bold'>
        #{ inline_svg_tag('workarea/admin/icons/wysiwyg/bold.svg', class: 'wysiwyg__toolbar-button-icon svg-icon', title: I18n.t('workarea.admin.js.wysiwyg.bold')) }
      </a>
      <a class='wysiwyg__toolbar-button' data-wysihtml-command='italic'>
        #{ inline_svg_tag('workarea/admin/icons/wysiwyg/italic.svg', class: 'wysiwyg__toolbar-button-icon svg-icon', title: I18n.t('workarea.admin.js.wysiwyg.italic')) }
      </a>
      <a class='wysiwyg__toolbar-button' data-wysihtml-command='underline'>
        #{ inline_svg_tag('workarea/admin/icons/wysiwyg/underline.svg', class: 'wysiwyg__toolbar-button-icon svg-icon', title: I18n.t('workarea.admin.js.wysiwyg.underline')) }
      </a>

      <a class='wysiwyg__toolbar-button' data-wysihtml-command='insertUnorderedList'>
        #{ inline_svg_tag('workarea/admin/icons/wysiwyg/bulleted_list.svg', class: 'wysiwyg__toolbar-button-icon svg-icon', title: I18n.t('workarea.admin.js.wysiwyg.bulleted_list')) }
      </a>
      <a class='wysiwyg__toolbar-button' data-wysihtml-command='insertOrderedList'>
        #{ inline_svg_tag('workarea/admin/icons/wysiwyg/numbered_list.svg', class: 'wysiwyg__toolbar-button-icon svg-icon', title: I18n.t('workarea.admin.js.wysiwyg.numbered_list')) }
      </a>

      <a class='wysiwyg__toolbar-button' data-wysihtml-action='change_view'>
        #{ inline_svg_tag('workarea/admin/icons/wysiwyg/html.svg', class: 'wysiwyg__toolbar-button-icon svg-icon', title: I18n.t('workarea.admin.js.wysiwyg.html')) }
      </a>
      <a class='wysiwyg__toolbar-button' data-wysihtml-command='createLink'>
        #{ inline_svg_tag('workarea/admin/icons/wysiwyg/link.svg', class: 'wysiwyg__toolbar-button-icon svg-icon', title: I18n.t('workarea.admin.js.wysiwyg.insert_link')) }
      </a>

      <div class='wysiwyg__dialog' data-wysihtml-dialog='createLink' style='display: none;'>
        <div class='grid grid--bottom'>
          <div class='grid__cell grid__cell--80'>
            <div class='property property--inline-with-label'>
              <label class='property__name'>#{ I18n.t('workarea.admin.js.wysiwyg.link') }</label>
              <input class='text-box' data-wysihtml-dialog-field='href' value='http://'>
            </div>
          </div>
          <div class='grid__cell grid__cell--20'>
            <a class='button button--create' data-wysihtml-dialog-action='save'>#{ I18n.t('workarea.admin.js.wysiwyg.insert') }</a>
          </div>
        </div>
      </div>
  </div>
}
