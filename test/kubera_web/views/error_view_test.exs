defmodule KuberaWeb.ErrorViewTest do
  use KuberaWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(KuberaWeb.ErrorView, "404.json", []) ==
           %{code: 404, title: "Resource not found", reason: ""}
  end

  test "render 500.json" do
    assert render(KuberaWeb.ErrorView, "500.json", []) ==
           %{code: 500, title: "Internal Server Error", reason: ""}
  end

  test "render any other" do
    assert render(KuberaWeb.ErrorView, "505.json", []) ==
           %{code: 500, title: "Internal Server Error", reason: ""}
  end
end
