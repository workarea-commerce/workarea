import pluralize from "pluralize"

export default class DuplicateIdsError extends Error {
  constructor(ids) {
    const dupes = pluralize("duplicate ID attribute value", ids.length)
    const page = `page ${window.location.pathname}`

    super(`${dupes} found on ${page}`)
  }
}
