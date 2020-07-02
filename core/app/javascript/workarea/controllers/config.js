import TestAdapter from "./models/adapters/test_adapter"

export const date = {
    format: '%Y-%m-%d %I:%M %P %:z',
    formatDate: '%Y-%m-%d',
    hours: '%I',
    minutes: '%M',
    ampm: '%P'
}

export const categorizedAutocompleteFields = {
    uiOptions: {
        minLength: 2
    }
}

export const deletionForms = {
    message: 'Are you sure you want to delete this?'
}

export const imageFileExtensions = ['jpg', 'jpeg', 'gif', 'png']

export const autosubmit = {
    changeDelay: 500,
    inputDelay: 1000
}

export const analytics = {
  adapters: [TestAdapter]
}

export default { date, categorizedAutocompleteFields, deletionForms, imageFileExtensions, autosubmit, analytics }
