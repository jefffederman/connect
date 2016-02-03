class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :oauth_callback, :destroy]

  def new
    if namely_subdomain.present?
      if logged_in?
        redirect_to dashboard_path
      else
        redirect_to namely_authentication_url
      end
    else
      redirect_to root_path
    end
  end

  def oauth_callback
    session[:current_user_id] = new_session.user_id

    if logged_in?
      redirect_to(
        dashboard_path,
        notice: t("flashes.sign_in_succeeded", name: current_user.full_name),
      )
    else
      redirect_to root_path, notice: t("flashes.sign_in_failed")
    end
  end

  def destroy
    session[:current_user_id] = nil
    redirect_to root_path, notice: t("flashes.signed_out")
  end

  private

  def new_session
    Session.new(
      authenticator(params.fetch(:state)),
      code: params.fetch(:code),
      subdomain: params.fetch(:state),
    )
  end

  def namely_authentication_url
    authenticator(namely_subdomain).authorization_code_url(session_oauth_callback_url)
  end

  def authenticator(subdomain)
    Authenticator.new(subdomain)
  end

  def namely_subdomain
    params.require(:namely_authentication).fetch(:subdomain)
  end

end
