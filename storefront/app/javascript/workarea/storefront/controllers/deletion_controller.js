import DeletionController from "workarea/controllers/deletion_controller"

export default class StorefrontDeletionController extends DeletionController {
  get config() {
    return this.app.config.deletion
  }

  get message() {
    return super.message || this.config.message
  }
}
