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
    # 3. Rate limit (DRESA-81, 9 Nov 2026): at most 3 messages per sender address per hour and 20 a day
    #    in total. Over the limit, drop the message quietly, like the checks above.
    if contact_rate_limited?
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

  private

  # DRESA-81: limits for the contact form (see create, check 3).
  CONTACT_PER_ADDRESS_PER_HOUR = 3
  CONTACT_PER_DAY = 20

  # Counts this message against both limits in Redis (shared by all app workers; each counter
  # expires on its own) and says whether either limit is now exceeded.
  def contact_rate_limited?
    now = Time.now.utc
    address_key = "contact_form:address:#{request.remote_ip}:#{now.strftime('%Y%m%d%H')}"
    day_key = "contact_form:day:#{now.strftime('%Y%m%d')}"
    per_address, per_day = Sidekiq.redis do |r|
      a = r.call('INCR', address_key); r.call('EXPIRE', address_key, 2 * 3600)
      d = r.call('INCR', day_key);     r.call('EXPIRE', day_key, 2 * 86_400)
      [a, d]
    end
    if per_address > CONTACT_PER_ADDRESS_PER_HOUR || per_day > CONTACT_PER_DAY
      Rails.logger.info("[contact_form] blocked: rate limit (#{per_address} this hour from this address, #{per_day} today)")
      return true
    end
    false
  rescue StandardError => e
    # Never block genuine mail because the counter store had a problem.
    Rails.logger.warn("[contact_form] rate limit check skipped: #{e.class}")
    false
  end

end
