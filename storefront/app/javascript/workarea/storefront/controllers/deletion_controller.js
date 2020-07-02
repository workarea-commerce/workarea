import DeletionController from "workarea/controllers/deletion_controller"
import App from "storefront/application"

export default class extends DeletionController {
  get message() {
    return super.message || App.config.deletion.message
  }
}
