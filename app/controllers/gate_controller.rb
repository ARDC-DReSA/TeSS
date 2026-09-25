# DReSA: challenge page used by the nginx bot-control "gate" (see the
# dresa-migration repo's nginx config). nginx 302s unauthenticated bot-like
# traffic to /gate?next=<original path>; humans log in and continue.
# Currently dormant (gates disabled at nginx since 2026-09-08) but kept so
# the gate can be re-enabled at any time.
class GateController < ApplicationController
  def show
    # Only ever redirect within this site (open-redirect hardening):
    # accept a plain local path like "/materials", reject absolute URLs
    # ("https://evil.example"), protocol-relative URLs ("//evil.example")
    # and backslash tricks ("/\evil.example").
    requested = params[:next].to_s
    safe = requested.start_with?("/") &&
           !requested.start_with?("//") &&
           !requested.include?("\\")
    @next = safe ? requested : "/"

    # If already logged in, send them straight to the target page
    redirect_to @next if user_signed_in?
  end
end
