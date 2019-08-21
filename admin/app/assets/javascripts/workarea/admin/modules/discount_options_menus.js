/**
 * @namespace WORKAREA.discountOptionsMenus
 */
WORKAREA.registerModule('discountOptionsMenus', (function () {
    'use strict';

    var getMenu = function (event) {
            return $(event.target);
        },

        getSelectedValue = function ($menu) {
            return $menu.val();
        },

       deactivateGroups  = function ($groups) {
            $groups
            .removeClass('discount__optional-node-group--visible')
                .find('[name^=discount]')
                .val('');
        },

        activateGroup = function ($group) {
            $group.addClass('discount__optional-node-group--visible');
        },

        setConditionOptionsDisplay = function (selectedValue) {
            var $conditionGroups = $(
                    '[data-discount-options-menu-condition-group]', $(document)
                ),
                $selectedGroup = $conditionGroups.filter(function () {
                    var groupType = $(this).data('discountOptionsMenuConditionGroup').type;

                    return groupType === selectedValue;
                }),
                $otherGroups = $conditionGroups.not($selectedGroup);

            activateGroup($selectedGroup);
            deactivateGroups($otherGroups);
        },

        updateConditionOptionsDisplay = _.flowRight(setConditionOptionsDisplay, getSelectedValue),

        setApplicationOptionsDisplay = function (selectedValue) {
            var $applicationGroups = $(
                    '[data-discount-options-menu-application-group]',
                    $('.discount__rules')
                ),
                $selectedGroup = $applicationGroups.filter(function () {
                    var groupType = $(this).data('discountOptionsMenuApplicationGroup').type;

                    return groupType === selectedValue;
                }),
                $otherGroups = $applicationGroups.not($selectedGroup);

            activateGroup($selectedGroup);
            deactivateGroups($otherGroups);
        },

        updateApplicationOptionsDisplay = _.flowRight(setApplicationOptionsDisplay, getSelectedValue),

        setPromoCodeOptionsDisplay = function (selectedValue) {
            var $promoCodeGroups = $(
                    '[data-discount-options-menu-promo-code-group]', $(document)
                ),
                $selectedGroup = $promoCodeGroups.filter(function () {
                    var groupType = $(this).data('discountOptionsMenuPromoCodeGroup').type;

                    return groupType === selectedValue;
                }),
                $otherGroups = $promoCodeGroups.not($selectedGroup);

            activateGroup($selectedGroup);
            deactivateGroups($otherGroups);
        },

        updatePromoCodeOptionsDisplay = _.flowRight(setPromoCodeOptionsDisplay, getSelectedValue),

        mediateOptionMenus = function (index, menu) {
            var $menu = $(menu),
                menuType = $menu.data('discountOptionsMenu').type;

            if (menuType === 'condition') {
                updateConditionOptionsDisplay($menu);

                $menu.on('change',
                    _.flowRight(updateConditionOptionsDisplay, getMenu)
                );
            } else if (menuType === 'application') {
                updateApplicationOptionsDisplay($menu);

                $menu.on('change',
                    _.flowRight(updateApplicationOptionsDisplay, getMenu)
                );
            } else if (menuType === 'promo') {
                updatePromoCodeOptionsDisplay($menu);

                $menu.on('change',
                    _.flowRight(updatePromoCodeOptionsDisplay, getMenu)
                );
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.discountOptionsMenus
         */
        init = function ($scope) {
            $('[data-discount-options-menu]', $scope).each(mediateOptionMenus);
        };

    return {
        init: init
    };
}()));
