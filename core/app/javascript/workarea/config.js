import TestAdapter from "./models/adapters/test_adapter"

export default {
    date: {
        format: '%Y-%m-%d %I:%M %P %:z',
        formatDate: '%Y-%m-%d',
        hours: '%I',
        minutes: '%M',
        ampm: '%P'
    },

    categorizedAutocompleteFields: {
        uiOptions: {
            minLength: 2
        }
    },

    deletionForms: {
        message: 'Are you sure you want to delete this?'
    },

    imageFileExtensions: ['jpg', 'jpeg', 'gif', 'png'],

    autosubmit: {
        changeDelay: 500,
        inputDelay: 1000
    },

    analytics: {
      adapters: [TestAdapter]
    }
}
