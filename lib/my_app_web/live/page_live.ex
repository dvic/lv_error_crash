defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:uploaded_paths, [])
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 2, external: &presign_upload/2)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_paths =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry -> path end)

    {:noreply, update(socket, :uploaded_paths, &(&1 ++ uploaded_paths))}
  end

  defp presign_upload(_entry, socket) do
    meta = %{uploader: "Gcs", endpoint: "http://localhost:4000/upload"}
    {:ok, meta, socket}
  end

  def error_to_string(:external_client_failure), do: "External client failure"
  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
