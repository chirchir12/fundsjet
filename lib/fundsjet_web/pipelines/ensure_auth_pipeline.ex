defmodule FundsjetWeb.Pipelines.EnsureAuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :fundsjet,
    error_handler: FundsjetWeb.Errors.GuardianAuthErrorHandler,
    module: Fundsjet.Identity.Auth.Guardian

  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
