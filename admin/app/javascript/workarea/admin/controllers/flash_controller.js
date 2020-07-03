import FlashController from "workarea/controllers/flash_controller"
import Message from "../templates/message.ejs"

export default class AdminFlashController extends FlashController {
  get template() {
    return Message
  }
}
