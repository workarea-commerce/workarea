import { Controller } from "stimulus"
import MenuTemplate from "../templates/tabs_menu.ejs"
import $ from 'jquery'
import { paramCase } from "workarea/helpers/string"
import zip from "lodash.zip"

import 'jquery-ui/ui/widgets/tabs'

export default class TabsController extends Controller {
  static target = ['panel', 'menu']

  get tabNames() {
    return this.panelTargets.map(panel => (
      panel.querySelectorAll('.tabs__heading').map(heading => (
        heading.innerText.trim()
      ))
    )).flat()
  }

  get tabIds() {
    return this.tabNames.map((name, index) => {
      const id = paramCase(name)

      return `${id}-${index}`
    })
  }

  get tabMenuData() {
    return zip(this.tabNames, this.tabIds)
  }

  get tabIndex() {
    return this.data.get('tabIndex')
  }

  setPanelIds() {
    this.panelTargets.forEach((panel, index) => {
      const tab = this.tabIds[index]
      const id = `${tab}-tab-panel-${this.tabIndex}`

      panel.setAttribute('id', id)
    })
  }

  injectTabMenu() {
    this.element.insertAdjacentHTML("afterbegin", MenuTemplate({
      tabs: this.tabMenuData,
      tabIndex: this.tabIndex
    }))
  }

  setupTabs() {
    $(this.element).tabs()
  }

  findTabIndex() {
    const tabs = document.querySelectorAll('[data-controller="tabs"]')

    this.data.set('tabIndex', tabs.indexOf(this.element))
  }

  connect() {
    this.findTabIndex()
    this.setPanelIds()
    this.injectTabMenu()
    this.setupTabs()
  }

  disconnect() {
    this.destroy()
  }

  destroy() {
    this.menuTarget.remove()
  }
}
