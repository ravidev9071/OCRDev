import { LightningElement, track, api } from 'lwc'
    import getActiveUserByEmail from '@salesforce/apex/xiaflexCustomPortalController.getActiveUserByEmail'
    import createCommunityUser from '@salesforce/apex/xiaflexCustomPortalController.createCommunityUser'

    import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class xiaflex_passwordSetup extends LightningElement {
  email = ''
  @track password = ''
  @track confirmPassword = ''
  @track passwordErrorMessage = ''
  @track confirmPasswordErrorMessage = ''
  @track isPasswordValid = false
  existingUser = false
  saveClicked = false
  displaySpinner = false
    @api programType
    @api profileName
  @track persona = '';
    @track sendemailback = '';
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
     if(emailParam != null){
      var emailss = emailParam.split('/');
       this.sendemailback = emailss[0];
      this.persona = emailss[1];
       }
    if (this.sendemailback) {
      this.email = this.sendemailback
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
      return this.passwordErrorMessage;
   }

    if (
      this.password !== this.confirmPassword &&
      (this.confirmPassword != '' || this.saveClicked)
    ) {
      this.confirmPasswordErrorMessage = 'Passwords do not match.'
      this.isPasswordValid = false
      return this.confirmPasswordErrorMessage;
    }
    this.isPasswordValid = true
  }

  handleSearch () {
    getActiveUserByEmail({ email: this.email,persona: this.persona })
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
    let errorMessage = this.validatePasswords();
    if (this.validatePolicy()) {
      this.displaySpinner = true
      createCommunityUser({ contactEmail: this.email, pwd: this.password,persona:  this.persona, programType : this.programType, profileName : this.profileName})
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
    } else if(!this.isPasswordValid){
          this.displaySpinner = false;
          this.showToast('Error', errorMessage, 'error');
    }
  }
}