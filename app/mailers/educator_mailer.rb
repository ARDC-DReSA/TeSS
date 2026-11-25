# frozen_string_literal: true

# DRESA-96 (Nov 2026): DReSA's own mailer for the Educators page.
# When someone who is not a curator or admin adds a tile, it goes live at once
# and this email tells the site contact (TeSS::Config.contact_email), so a
# curator can look at it and hide or remove it if it does not belong.
class EducatorMailer < ApplicationMailer
  def new_tile(educator)
    @educator = educator
    @user = educator.user
    subject = "#{TeSS::Config.site['title_short']}: new Educators tile \"#{educator.title}\" (please check)"
    mail(subject:, to: TeSS::Config.contact_email) do |format|
      format.text
    end
  end
end
