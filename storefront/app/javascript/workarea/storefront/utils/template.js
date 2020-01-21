/**
 * Create an `HTMLElement` from an EJS template.
 */
export default function(template, locals = {}) {
  const element = document.createElement("template")
  element.textContent = template(locals)

  return element.firstChild
}
