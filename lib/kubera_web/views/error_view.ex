defmodule KuberaWeb.ErrorView do
  use KuberaWeb, :view

  alias KuberaWeb.ErrorView
  import Plug.Conn

  def render("400.json", _assigns) do
    build_response("Bad Request", 400)
  end

  def render("401.json", _assigns) do
    build_response("Unauthorized", 401)
  end

  def render("403.json", _assigns) do
    build_response("Forbidden", 403)
  end

  def render("404.json", _assigns) do
    build_response("Resource not found", 404)
  end

  def render("422.json", _assigns) do
    build_response("Unprocessable entity", 422)
  end

  def render("500.json", assigns) do
    message = Map.get(assigns, :message, "")
    build_response("Internal Server Error", 500, message)
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end

  def send_error(conn, status, message \\ "") do
    conn
    |> put_status(status)
    |> Phoenix.Controller.render(ErrorView, to_string(status) <> ".json", message: message)
  end

  defp build_response(message, code, reason \\ "") do
    %{title: message, code: code, reason: reason}
  end
end
