class ContactFormController < ApplicationController

  def create
    @name = params[:contact_form][:name]
    @phone = params[:contact_form][:phone]
    @type = params[:contact_form][:message_type]
    @email = params[:contact_form][:email]
    @message = params[:contact_form][:message]

    # Perform any necessary actions with the form data
    ContactMailer.contact(@name, @phone, @email, @message, @type).deliver_now
    #ContactFormMailer.welcome_email.deliver_now
    flash[:success] = "Your message has been sent successfully."
    redirect_to :root
  end

end
