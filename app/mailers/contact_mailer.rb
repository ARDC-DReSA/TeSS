class ContactMailer < ApplicationMailer
  
  default to: "yuan.ma@anu.edu.au",
  from: "contact@dresa.org.au"
 
  def contact(name,phone,email,message,type)
    @name = name
    @email = email
    @phone = phone
    @type = type
    @message = message
    mail(to: 'contact@dresa.org.au', subject: 'New contact form message')
  end

  def simple_message(first_name, last_name, email, message)
    mail(
      subject: "New contact form message",
      body: message
    )
  end

end
