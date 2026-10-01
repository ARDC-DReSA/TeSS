class ContactMailer < ApplicationMailer
  # DReSA contact form: delivered to the DReSA inbox, with Reply-To set to the
  # person who wrote in (when their address is valid) so staff can just reply.
  def contact(name,phone,email,message,type)
    @name = name
    @email = email
    @phone = phone
    @type = type
    @message = message
    options = { to: TeSS::Config.contact_email, subject: 'New contact form message' }
    options[:reply_to] = email.to_s.strip if email.to_s.strip.match?(URI::MailTo::EMAIL_REGEXP)
    mail(options)
  end

end
