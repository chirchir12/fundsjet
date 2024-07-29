defmodule FundsjetWeb.Pipelines.MybeAuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :fundsjet,
    error_handler: FundsjetWeb.Errors.GuardianAuthErrorHandler,
    module: Fundsjet.Identity.Auth.Guardian

  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource, allow_blank: true
end
