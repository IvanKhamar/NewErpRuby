# Values of these parameters never reach the logs (partial match: :passw also hides password and current_password).
Rails.application.config.filter_parameters += %i[
  passw email secret token _key crypt salt certificate otp ssn cvv cvc
  telephone phone iban signature
]
