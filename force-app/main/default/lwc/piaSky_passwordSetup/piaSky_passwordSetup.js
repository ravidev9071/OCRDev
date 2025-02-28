import { LightningElement, track } from 'lwc'
import getActiveUserByEmail from '@salesforce/apex/PiaSkyCustomPortalController.getActiveUserByEmail'
import createCommunityUser from '@salesforce/apex/PiaSkyCustomPortalController.createCommunityUser'

import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class PiaSky_passwordSetup extends LightningElement {
  email = ''
  @track password = ''
  @track confirmPassword = ''
  @track passwordErrorMessage = ''
  @track confirmPasswordErrorMessage = ''
  @track isPasswordValid = false
  existingUser = false
  saveClicked = false
  displaySpinner = false
  connectedCallback () {
    this.getQueryParameters()
    this.handleSearch()
  }

  getQueryParameters () {
    // Get the query string from the current URL
    const queryString = window.location.search

    // Parse the query string
    const urlParams = new URLSearchParams(queryString)

    // Get the value of a specific parameter, for example 'email'
    const emailParam = urlParams.get('email')

    if (emailParam) {
      this.email = emailParam
    }
  }
  handleChange (event) {
    const { name, value } = event.target

    if (name === 'password') {
      this.password = value
    } else if (name === 'confirmPassword') {
      this.confirmPassword = value
    }

    this.validatePasswords()
  }
  validatePasswords () {
    const minLength = 8
    this.passwordErrorMessage = ''
    this.confirmPasswordErrorMessage = ''

    if (this.password.length < minLength) {
      this.passwordErrorMessage = `Password must be at least ${minLength} characters long.`
      this.isPasswordValid = false
      return
    }

    if (
      this.password !== this.confirmPassword &&
      (this.confirmPassword != '' || this.saveClicked)
    ) {
      this.confirmPasswordErrorMessage = 'Passwords do not match.'
      this.isPasswordValid = false
      return
    }

    this.isPasswordValid = true
  }

  handleSearch () {
    getActiveUserByEmail({ email: this.email })
      .then(result => {
        if (result !== 'No user') {
          this.existingUser = true
          this.showToast('Error', result, 'error')
        }
      })
      .catch(error => {
        this.error = error.body.message
        this.showToast('Error', this.error, 'error')
        this.existingUser = true
      })
  }

  showToast (title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: 'dismissable'
    })
    this.dispatchEvent(event)
  }

  validatePolicy () {
    return !this.existingUser && this.isPasswordValid
  }

  isStringNullOrWhitespace (input) {
    // Check if the input is null, undefined, or consists only of whitespace characters
    return !input || input.trim().length === 0
  }

  handleSave () {
    this.saveClicked = true
    this.validatePasswords()
    if (this.validatePolicy()) {
      this.displaySpinner = true
      createCommunityUser({ contactEmail: this.email, pwd: this.password })
        .then(result => {
          this.displaySpinner = false
          this.showToast('Success','Password Updated Successfully.','success');
          window.location.href = result;
        })
        .catch(error => {
          this.displaySpinner = false
          this.error = error.body.message
          this.showToast('Error', this.error, 'error')
        })
    }
  }
}