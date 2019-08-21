/**
 * @namespace WORKAREA.contentBlocks
 */
WORKAREA.registerModule('contentBlocks', (function () {
    'use strict';

    var iframe = JST['workarea/admin/templates/content_block_iframe'],
        loadingIndicator = JST['workarea/admin/templates/loading'],

        /**
         * Utility
         */

        allIframesLoaded = function ($iframe) {
            var $container = $iframe.closest('.content-editor__area'),
                $allIframes = $('.content-block__iframe', $container),
                $loadedIframes = $allIframes.filter(function (index, iframe) {
                    return $(iframe).data('contentBlockIframeLoaded');
                });

            return $loadedIframes.length === $allIframes.length;
        },

        withinViewport = function ($block) {
            var rect = $block[0].getBoundingClientRect();

            return (
                rect.top >= 0 &&
                rect.left >= 0 &&
                rect.bottom <= $(window).height() &&
                rect.right <= $(window).width()
            );
        },

        scrollToNewBlock = function () {
            var $newBlock = $('#new_content_block'),
                offsets = {};

            if (_.isEmpty($newBlock)) { return; }
            if (withinViewport($newBlock)) { return; }

            offsets.newBlock = $newBlock.offset().top;
            offsets.header = $('#header').height();

            $(window).scrollTop(offsets.newBlock - offsets.header - 48);
        },


        /**
         * Handle Loading Indicator
         */

        stopLoading = _.flow(scrollToNewBlock, WORKAREA.takeover.close),

        ensureLoadingIndicatorCloses = function () {
            var timer = _.delay(
                stopLoading, WORKAREA.config.contentBlocks.loadingTimeout
            );

            $(window).on('contentBlocks:blocksLoaded', function () {
                window.clearTimeout(timer);
            });
        },

        openLoadingIndicator = function () {
            WORKAREA.takeover.open(loadingIndicator({
                cssModifiers: 'loading--large loading--fill-parent'
            }));
        },

        loading = _.flow(openLoadingIndicator, ensureLoadingIndicatorCloses),


        /**
         * Handle Block Activation
         */

        hideEditorAside = function ($activeBlock) {
            var $editor = $activeBlock.closest('.content-editor');

            $('.content-editor__aside', $editor).hide();
            $editor.trigger('close:contentEditorAside');
        },

        showEditorAside = function ($activeBlock) {
            var $editor = $activeBlock.closest('.content-editor');

            $('.content-editor__aside', $editor).show();
            $editor.trigger('open:contentEditorAside');
        },

        /**
         * @method
         * @name activateBlock
         * @memberof WORKAREA.contentBlocks
         */
        activateBlock = function ($activeBlock) {
            var $otherBlocks = $activeBlock.siblings('.content-block');

            $activeBlock
            .addClass('content-block--active')
            .removeClass('content-block--inactive');

            $otherBlocks
            .addClass('content-block--inactive')
            .removeClass('content-block--active');

            hideEditorAside($activeBlock);

            return $activeBlock;
        },

        /**
         * @method
         * @name deactivateBlock
         * @memberof WORKAREA.contentBlocks
         */
        deactivateBlock = function ($activeBlock) {
            var $editor = $activeBlock.closest('.content-editor'),
                $blocks = $('.content-block', $editor);

            $blocks
            .removeClass('content-block--active')
            .removeClass('content-block--inactive');

            showEditorAside($activeBlock);

            return $activeBlock;
        },

        handleBlockActivation = function(event) {
            var $activeBlock = $(event.currentTarget).closest('.content-block');

            event.preventDefault();

            activateBlock($activeBlock);
        },

        /**
         * Manage Block Heights
         */

        observeAsyncBlocks = function ($iframe, iframeBlock) {
            var observer = new window.MutationObserver(function () {
                setBlockHeight($iframe, iframeBlock);
            });

            try {
                observer.observe(iframeBlock, {
                    childList: true,
                    subtree: true
                });
            } catch (error) {
                if ( ! _.includes(error.message, 'MutationObserver')) {
                    throw new Error(error);
                }

                window.console.warn(
                    'WORKAREA.contentBlocks.observeAsyncBlocks: the ' +
                    'following content block has failed to load:',
                    $iframe,
                    '\n\nThis is a known, development-only issue. If this ' +
                    'becomes a nuisance, you can avoid this issue by running ' +
                    'a single-threaded development server, like `thin`.'
                );
            }
        },

        setBlockHeight = function ($iframe, iframeBlock) {
            $iframe.height($(iframeBlock).height());
        },

        resetBlockHeight = function (index, block) {
            var $iframe = $('.content-block__iframe', block),
                iframeDocument = $iframe[0].contentDocument,
                iframeBlock = $('[data-content-block]', iframeDocument)[0];

            setBlockHeight($iframe, iframeBlock);
        },

        listenForWindowResize = _.once(function ($blocks) {
            $(window).on('resize', _.debounce(function () {
                $blocks.each(resetBlockHeight);
            }, 250));
        }),


        /**
         * Iframe Setup
         */

        setupIframe = function (event) {
            var $iframe = $(event.currentTarget),
                iframeDocument = event.currentTarget.contentDocument,
                iframeBlock = $('[data-content-block]', iframeDocument)[0];

            $iframe.data('contentBlockIframeLoaded', true);

            $iframe
                .next('.content-block__overlay')
                .on('click', handleBlockActivation);

            setBlockHeight($iframe, iframeBlock);
            observeAsyncBlocks($iframe, iframeBlock);

            if (allIframesLoaded($iframe)) {
                stopLoading();
                $(window).trigger('contentBlocks:blocksLoaded');
            }
        },

        injectIframe = function (index, block) {
            var $block = $(block),
                $placeholder = $('.content-block__iframe-placeholder', $block),
                src = $block.data('contentBlock'),
                $iframe = $(iframe({ src: src }));

            $placeholder.replaceWith($iframe);
            $iframe.on('load', setupIframe);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.contentBlocks
         */
        init = function ($scope) {
            var $blocks = $('[data-content-block]', $scope);

            if (_.isEmpty($blocks)) { return; }

            loading();
            listenForWindowResize($blocks);

            $blocks
            .each(injectIframe)
                .filter('.content-block--active')
                .each(function(index, activeBlock) {
                    hideEditorAside($(activeBlock));
                });
        };

    return {
        init: init,
        activateBlock: activateBlock,
        deactivateBlock: deactivateBlock
    };
}()));
