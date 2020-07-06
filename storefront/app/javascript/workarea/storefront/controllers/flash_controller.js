import FlashController from "@workarea/core/workarea/controllers/flash_controller"
import Message from "../templates/message.ejs"

export default class StorefrontFlashController extends FlashController {
  get template() {
    return Message
  }
}
