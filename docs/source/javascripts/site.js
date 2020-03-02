'use strict';

const plugins = [
    {
        matches: ['moneris'],
        displayName: 'Moneris',
        gitHubKey: 'workarea-moneris'
    },
    {
        matches: ['paypal', 'pay pal'],
        displayName: 'PayPal',
        gitHubKey: 'workarea-paypal'
    },
    {
        matches: ['afterpay', 'after pay'],
        displayName: 'Afterpay',
        gitHubKey: 'workarea-afterpay'
    },
    {
        matches: ['emarsys'],
        displayName: 'Emarsys',
        gitHubKey: 'workarea-emarsys'
    },
    {
        matches: ['flow', 'flow io'],
        displayName: 'Flow IO',
        gitHubKey: 'workarea-flow-io'
    },
    {
        matches: ['reviews'],
        displayName: 'Workarea Reviews',
        gitHubKey: 'workarea-reviews'
    },
    {
        matches: ['avatax', 'avalara'],
        displayName: 'Avatax',
        gitHubKey: 'workarea-avatax'
    },
    {
        matches: ['clifton'],
        displayName: 'Clifton Theme',
        gitHubKey: 'workarea-clifton-theme'
    },
    {
        matches: ['forter', 'forter fraud'],
        displayName: 'Forter',
        gitHubKey: 'workarea-forter'
    },
    {
        matches: ['nvy', 'envy'],
        displayName: 'NVY Theme',
        gitHubKey: 'workarea-nvy-theme'
    },
    {
        matches: ['braintree', 'brain tree'],
        displayName: 'Braintree Payments',
        gitHubKey: 'workarea-braintree'
    },
    {
        matches: ['authorize', 'CIM', 'authorize.net'],
        displayName: 'Authorize.net',
        gitHubKey: 'workarea-authorize-cim'
    },
    {
        matches: ['super hero', 'superhero'],
        displayName: 'Super Hero Content Block',
        gitHubKey: 'workarea-super-hero'
    },
    {
        matches: ['wish lists', 'wishlist'],
        displayName: 'Workarea Wish List',
        gitHubKey: 'workarea-wish-lists'
    },
    {
        matches: ['zendesk', 'zen desk'],
        displayName: 'Zendesk',
        gitHubKey: 'workarea-zendesk'
    },
    {
        matches: ['product documents', 'documents'],
        displayName: 'Workarea Product Documents',
        gitHubKey: 'workarea-product-documents'
    },
    {
        matches: ['yotpo'],
        displayName: 'Yotpo',
        gitHubKey: 'workarea-yotpo'
    },
    {
        matches: ['facebook login', 'facebook'],
        displayName: 'Facebook Login',
        gitHubKey: 'workarea-facebook-login'
    },
    {
        matches: ['gift wrapping', 'wrapping'],
        displayName: 'Workarea Gift Wrapping',
        gitHubKey: 'workarea-gift-wrapping'
    },
    {
        matches: ['save for later'],
        displayName: 'Workarea Save For Later',
        gitHubKey: 'workarea-save-for-later'
    },
    {
        matches: ['payflow', 'pay flow pro', 'payflow pro'],
        displayName: 'Payflow Pro Payments',
        gitHubKey: 'workarea-payflow-pro'
    },
    {
        matches: ['shipstation', 'ship station'],
        displayName: 'ShipStation',
        gitHubKey: 'workarea-ship-station'
    }
];


/**
 * Highlight.js
 */
window.hljs.initHighlightingOnLoad();



/**
 * Modules
 */

window.modules = {};

window.modules.canIHazJS = (function () {
    $('html').removeClass('no-js');
}());

window.modules.search = (function () {
    var
        // geek'd from here: https://stackoverflow.com/a/901144
        getParameterByName = function (name, url) {
          if (!url) url = window.location.href;
          name = name.replace(/[[\]]/g, '\\$&');
          var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
          results = regex.exec(url);
          if (!results) return null;
          if (!results[2]) return '';
          return decodeURIComponent(results[2].replace(/\+/g, ' '));
        },

        handleCurrentQuery = function (lunr) {
            var query = getParameterByName('q');

            if ( ! query) { return; }

            $('#lunr-search').val(query);
            display(lunr.index.search(query), pluginResult(query), lunr);
        },

        /* --- */

        resultListItemTPL = function (url, title, excerpt) {
            var item = '';

            item += '<li class="search-results__item">';
            item += '<a class="search-results__title" href="' + url + '">';
            item += title;
            item += '</a>';

            if (excerpt) {
              item += '<p class="search-results__excerpt">' + excerpt + '</p>';
            }

            item += '</li>';

            return item;
        },

        pluginResultListItemTPL = function (name, gitHubKey) {
            var item = '';
            item += '<p class="search-results__title"> Looking for the ' + name + " plugin? - ";
            item += '<a href="https://github.com/workarea-commerce/' + gitHubKey + '">';
            item += 'View it on Github';
            item += '</a>';
            item += '</p>';

            return item;
        },

        constructResultList = function (results, lunr) {
            var doc, list = '';

            for (var i = 0; i < results.length; i++) {
                doc = lunr.data.docs[results[i].ref];
                list += resultListItemTPL(doc.url, doc.title, doc.excerpt);
            }

            return list;
        },

        constructPluginResultList = function (results) {
            var plugin, list = '';

            $.each(results, function (i, plugin) {
                list += pluginResultListItemTPL(plugin.displayName, plugin.gitHubKey);
            });
            return list;
        },

        pluginResult = function (query) {
            var results = []

            $.each(plugins, function (i, plugin) {
                $.each(plugin.matches, function (j, match) {
                    if (match.toUpperCase() === query.toUpperCase()) {
                        results.push(plugin);
                    }
                });
            });

            return results;
        },


        constructCountMessage = function (length) {
            var message = 'Showing ' + length + ' result';

            if (length !== 1) {
                message += 's';
            }

            return message;
        },

        display = function (results, plugins, lunr) {
            var $countUI = $('.search-results__count'),
                $helpUI = $('.search-results__help'),
                $pluginUI = $('.search-results__plugins'),
                $resultListUI;

            if (plugins.length >= 0) {
                $pluginUI.html(constructPluginResultList(plugins));
                $pluginUI.show();
            } else {
                $pluginUI.hide();
            }

            if (results.length >= 0) {
                $resultListUI = $('.search-results__list');

                $countUI.text(constructCountMessage(results.length));
                $resultListUI.html(constructResultList(results, lunr));
            }

            if (results.length == 0) {
                $helpUI.show();
            } else {
                $helpUI.hide();
            }

            $countUI.show();
        },

        bindToSearchInput = function (lunr) {
            $('#lunr-search').on('keyup', function (event) {
                var results = lunr.index.search(event.target.value);
                var plugin = pluginResult(event.target.value);
                display(results, plugin, lunr);
            });
        },

        setup = function (lunr) {
            bindToSearchInput(lunr);
            handleCurrentQuery(lunr);
        },

        init = function () {
            if ($('#lunr-search').length === 0) { return; }

            $.getJSON('/search.json').done(function (data) {
                setup({
                    data: data,
                    index: window.lunr.Index.load(data.index)
                });
            });
        };

    return { init: init };
}());

window.modules.mobileNav = (function () {
    var toggle = function (event) {
            event.preventDefault();

            $(event.target)
                .closest('.header')
                    .find('.header__nav')
                    .toggleClass('header__nav--active');
        },

        init = function () {
            $('.header__icon-button--menu').on('click', toggle);
        };

    return { init: init };
}());

window.modules.asideMenu = (function () {
    var openNav = function (event) {
            $(event.target).addClass('hide');
            $(event.target).next('ul').removeClass('hide-for-pocket');
        },

        toggleActive = function (event) {
            var $nav = $(event.delegateTarget);

            $nav
            .toggleClass('active')
            .siblings()
                .removeClass('active');
        },

        setup = function (index, parent) {
            var $activeNode = $(parent).find('.active');

            if ($activeNode.length === 0) { return; }

            $(parent).addClass('active');
        },

        init = function () {
            $('.nav')
            .on('click', '[data-open-nav]', openNav)
                .find('> ul > li.parent')
                .on('click', '> .parent-label', toggleActive)
                .each(setup);
        };

    return { init: init };
}());

window.modules.uniqueArticleIDs = (function () {
    var uniqueId = function (index, id) {
            if (index > 0) {
                return id + '-' + (index + 1);
            } else {
                return id;
            }
        },

        ensureUniqueId = function (index, element) {
            $('[id="' + element.id + '"]').attr('id', uniqueId);
        },

        init = function () {
            $('[id]').each(ensureUniqueId);
        };

    return { init: init };
}());

window.modules.quickLinks = (function () {
    var icon = '<svg fill="#0060ff" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M472.021 39.991c-53.325-53.311-139.774-53.311-193.084 0l-76.184 76.154c6.031-.656 12.125-.938 18.25-.938 19.28 0 38.028 3.063 55.777 8.968l43.17-43.155c14.827-14.843 34.545-22.999 55.513-22.999 20.97 0 40.688 8.156 55.515 22.999 14.828 14.812 22.981 34.499 22.981 55.498 0 20.968-8.153 40.686-22.981 55.498l-84.465 84.466C331.687 291.326 311.968 299.48 291 299.48c-21 0-40.686-8.154-55.528-22.998a77.589 77.589 0 0 1-16.718-24.688c-9.625.531-18.624 4.531-25.499 11.405l-22.499 22.529c6.156 11.405 14.062 22.155 23.687 31.813 53.31 53.313 139.774 53.313 193.099 0l84.48-84.497c53.294-53.308 53.294-139.742-.001-193.053z"/><path d="M291.905 396.76c-19.312 0-38.248-3.125-56.402-9.281l-43.467 43.469c-14.812 14.844-34.529 22.999-55.497 22.999-20.968 0-40.654-8.155-55.498-22.999-14.843-14.813-22.999-34.529-22.999-55.498s8.156-40.688 22.999-55.529l84.465-84.465c14.843-14.812 34.53-22.968 55.498-22.968 20.999 0 40.686 8.156 55.512 22.968 7.22 7.218 12.857 15.593 16.75 24.717 9.656-.5 18.671-4.531 25.546-11.405l22.468-22.499c-6.156-11.438-14.078-22.187-23.718-31.843-53.31-53.311-139.774-53.311-193.084 0l-84.465 84.497c-53.341 53.313-53.341 139.744 0 193.086 53.31 53.313 139.744 53.313 193.053 0l76.058-76.059a185.02 185.02 0 0 1-17.187.813l-.032-.003z"/></svg>',

        copy = function (event) {
            $('#quick-link-input').val(event.currentTarget.href);
            $('#quick-link-input')[0].select();
            document.execCommand('copy');
        },

        appendInput = function () {
            $('body').append(function () {
                return $('<input>')
                            .attr({
                                id: 'quick-link-input',
                                type: 'text'
                            })
                            .css({
                                position: 'absolute',
                                left: '-99999999px'
                            })
                            .prop('outerHTML');
            });
        },

        appendLinks = function (heading) {
            $(heading).append(function () {
                var href = window.location.href.split('#')[0] + '#' + heading.id;

                return $('<a>')
                            .attr({
                                href: href,
                                title: 'Copy link to clipboard'
                            })
                            .addClass('quick-link')
                            .html(icon)
                            .prop('outerHTML');
            });
        },

        setup = function(index, heading) {
            appendLinks(heading);
        },

        init = function () {
            appendInput();

            $('.article')
                .find('h2, h3, h4, h5, h6')
                .each(setup)
                .on('click', '.quick-link', copy);
        };

    return { init: init };
}());

window.modules.skipTo = (function () {
    var buildLinks = function ($headings) {
            return $headings.map(function (index, heading) {
                var $link = $('<a>'),
                    tagName = heading.tagName.toLowerCase();

                $link
                .attr('href', '#' + heading.id)
                .addClass('skip-to__link skip-to__link--' + tagName)
                .text($(heading).text());

                return $link.wrap('<li>').parent().prop('outerHTML');
            }).toArray().join('');
        },

        addLinks = function ($skipTo) {
            var $article = $skipTo.closest('.grid').find('.article'),
                $headings = $article.find('h2, h3');

            if ($headings.length < 2) {
                $skipTo.remove();
            } else {
                $skipTo
                    .find('.skip-to__menu ul')
                    .html(buildLinks($headings));
            }
        },

        setup = function (index, skipTo) {
            var $skipTo = $(skipTo);
            addLinks($skipTo);
        },

        init = function () {
            $('.skip-to').each(setup);
        };

    return { init: init };
}());

window.modules.search.init();
window.modules.mobileNav.init();
window.modules.asideMenu.init();
window.modules.uniqueArticleIDs.init();
window.modules.quickLinks.init();
window.modules.skipTo.init();
