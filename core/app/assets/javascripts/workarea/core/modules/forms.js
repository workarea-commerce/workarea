// TODO v4 remove file
throw new Error(
    'WORKAREA.forms: you are receiving this error because this module has ' +
    'moved out of Core and into both the Admin and Storefront engines.\n\n' +
    'This change was made to solve an issue with the wrong classes being ' +
    'applied to label elements during Front-End Validation in the ' +
    'Storefront.\n\n' +
    'Make the following change in each overridden JavaScript manifest file ' +
    'to resolve this error:\n\n' +
    'For Admin: find `workarea/core/modules/forms` and replace with ' +
    '`workarea/admin/modules/forms`.\n\n' +
    'For Storefront: find `workarea/core/modules/forms` and replace with ' +
    '`workarea/storefront/modules/forms`.'
);
