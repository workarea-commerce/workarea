import isObject from "lodash.isobject"

const environment = document.querySelector('meta[property="environment"]')
                            .getAttribute("content");

export const isTest = environment === 'test' || isObject(window.Teaspoon)
export const isQA = environment === 'qa'
export const isDevelopment = environment === 'development'
export const isStaging = environment === 'staging'
export const isProduction = environment === 'production'

export default environment
