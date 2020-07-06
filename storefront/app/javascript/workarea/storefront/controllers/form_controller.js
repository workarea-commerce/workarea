import { Controller } from "stimulus"
import debounce from "lodash.debounce"
import rearg from "lodash.rearg"
import $ from "jquery"

export default class FormController extends Controller {
  invalidateProperty(index, error) {
    $(error).closest('.property').addClass('property--invalid')
  }

  displayError($error, $element) {
    $error.addClass(this.app.config.forms.errorLabelClasses)
    $element.closest('.value').append($error)
  }

  validateTextBox(element) {
    var $textBox = $(element)

    $textBox.removeClass('text-box--valid text-box--invalid')

    if ($textBox.valid()) {
      if ($textBox.val()) {
        $textBox.addClass('text-box--valid')
      }
    } else {
      $textBox.addClass('text-box--invalid')
    }
  }

  validateElement(element) {
    var $input = $(element),
      $property = $input.closest('.property')

    if ($input.valid()) {
      $property.removeClass('property--invalid')
      $property.find('.value__error').remove()
    } else {
      $property.addClass('property--invalid')
    }

    if ($(element).is('.text-box')) {
      this.validateTextBox(element)
    }
  }

  checkAllControls(event) {
    var $form = $(event.delegateTarget)

    if ($form.valid()) { return }

    $(':input', $form).each(rearg(this.validateElement, [1, 0]))
  }

  fireAnalytics() {
    // TODO fire analytics callback
  }

  setupValidation() {
    const throttle = this.app.config.validationErrorAnalyticsThrottle || 1000

    $(this.element).validate({
      onfocusout: this.validateElement,
      errorPlacement: this.displayError,
      invalidHandler: function () {
        if (this.app.config.analytics) {
          // debounced because jQuery.validate fires twice on submit
          debounce(this.fireAnalytics.bind(this), throttle)
        }
      }
    })

    $(this.element).on('submit', this.checkAllControls.bind(this))
  }

  connect() {
    this.setupValidation()
    this.errorTargets.forEach(this.invalidateProperty)
  }
}
