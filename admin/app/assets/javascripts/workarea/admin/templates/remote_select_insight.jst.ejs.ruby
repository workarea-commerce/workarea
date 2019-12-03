%{
    <span class="select2-results__option-content"<% if (title) { %> title="<%= title %>" <% } %>>
        <% if (!_.isEmpty(sparkline_data)) { %>
            <span class="select2-results__option-graph">
                <span class='spark' title= "#{I18n.t('workarea.admin.catalog_products.index.sparkline_title')}">
                  {<%= sparkline_data.join(',') %>}
                </span>
            </span>
        <% } %>

        <% if (top) { %>
            <span class="select2-results__option-icon">
                #{ inline_svg_tag('workarea/admin/icons/star.svg', title: I18n.t('workarea.admin.insights.icons.top_selling'), class: 'svg-icon svg-icon--small') }
            </span>
        <% } %>

        <% if (trending) { %>
            <span class="select2-results__option-icon">
                #{ inline_svg_tag('workarea/admin/icons/fire.svg', title: I18n.t('workarea.admin.insights.icons.trending'), class: 'svg-icon svg-icon--small') }
            </span>
        <% } %>

        <%= text %>
    </span>
}
