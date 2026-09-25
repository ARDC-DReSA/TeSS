# DReSA: challenge page used by the nginx bot-control "gate" (see the
# dresa-migration repo's nginx config). nginx 302s unauthenticated bot-like
# traffic to /gate?next=<original path>; humans log in and continue.
# Currently dormant (gates disabled at nginx since 2026-09-08) but kept so
# the gate can be re-enabled at any time.
class GateController < ApplicationController
  def show
    # Only ever redirect within this site: accept a plain path, reject
    # absolute URLs / protocol-relative URLs (open-redirect hardening).
    requested = params[:next].to_s
    @next = requested.match?(%r{\A/[^/\]}) ? requested : "/"

    # If already logged in, send them straight to the target page
    redirect_to @next if user_signed_in?
  end
end
