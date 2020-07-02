import { pluralize } from "../models/string"

export default class DuplicateIdsError extends Error {
  constructor(ids) {
    const values = pluralize(ids.length, "value")
    const page = `page ${window.location.pathname}`

    super(`${ids.length} duplicated ID attribute ${values} found on ${page}`)
  }
}
