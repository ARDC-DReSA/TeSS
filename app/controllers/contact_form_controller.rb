class ContactFormController < ApplicationController
  # DReSA: the contact form is public (upstream requires login by default)
  skip_before_action :authenticate_user!, :authenticate_user_from_token!, only: %i[new create]

  # DReSA spam check (Oct 2026): seconds a person needs, at least, to fill in the form
  MIN_SECONDS_TO_FILL = 4

  def create
    form = params[:contact_form] || {}
    # 1. The hidden "website" box: people never see it, so anything in it means a robot.
    #    Pretend it worked, so the robot learns nothing.
    if form[:website].present?
      Rails.logger.info("[contact_form] blocked: hidden field filled")
      flash[:success] = "Your message has been sent successfully."
      return redirect_to :root
    end
    # 2. The signed timestamp from when the page was shown.
    shown_at = Rails.application.message_verifier(:contact_form).verified(form[:rendered_at].to_s) rescue nil
    if shown_at.nil?
      # Missing or tampered with: a robot posting directly, or a very old open page. Ask to retry.
      Rails.logger.info("[contact_form] blocked: missing or invalid timestamp")
      flash[:error] = "Sorry, something went wrong sending your message. Please try again."
      return redirect_to contact_path
    end
    if Time.now.to_i - shown_at.to_i < MIN_SECONDS_TO_FILL
      Rails.logger.info("[contact_form] blocked: sent too fast")
      flash[:success] = "Your message has been sent successfully."
      return redirect_to :root
    end

    @name = params[:contact_form][:name]
    @phone = params[:contact_form][:phone]
    @type = params[:contact_form][:type]
    @email = params[:contact_form][:email]
    @message = params[:contact_form][:message]

    # Perform any necessary actions with the form data
    ContactMailer.contact(@name, @phone, @email, @message, @type).deliver_now
    #ContactFormMailer.welcome_email.deliver_now
    flash[:success] = "Your message has been sent successfully."
    redirect_to :root
  end

end
