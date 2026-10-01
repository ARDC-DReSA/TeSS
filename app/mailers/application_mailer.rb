class ApplicationMailer < ActionMailer::Base
  # DReSA: replies to any DReSA email reach the monitored contact inbox. A mailer
  # default (not a header) so Devise emails, e.g. password resets, use it too.
  default from: TeSS::Config.sender_email, reply_to: TeSS::Config.contact_email
  layout 'mailer'
  before_action :set_headers

  private

  def set_headers
    return unless TeSS::Config.mailer
    (TeSS::Config.mailer['headers'] || {}).each do |key, value|
      headers[key] = value
    end
  end
end
