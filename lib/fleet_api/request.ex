defmodule FleetApi.Request do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      require Logger
      # Issue a request to the specified url, optionally passing a list of header
      # tuples and a body. The method argument specifies the HTTP method in the
      # form of an atom, e.g. :get, :post, :delete, etc.
      @spec request(atom, String.t, [tuple], String.t, [integer], boolean) :: {:ok, any} | {:error, any}
      defp request(method, url, headers \\ [], body \\ "", expected_status \\ [200], parse_response \\ true) do
        options = case Application.get_env(:fleet_api, :proxy) do
          nil -> []
          proxy_opts -> [hackney: [proxy: proxy_opts]]
        end

        Logger.debug "[FleetApi] issuing request to #{url}"

        case HTTPoison.request(method, url, body, headers, options) do
          {:ok, %HTTPoison.Response{:status_code => status} = response} when status in 400..599 ->
            Logger.error "[FleetApi] request to #{url} returned status code #{inspect status}"
            if String.length(response.body) != 0 do
              error = response.body
                      |> Poison.decode!
                      |> FleetApi.Error.from_map
              {:error, %{reason: error}}
            else
              {:error, %{reason: "Received #{status} response."}}
            end
          {:ok, %HTTPoison.Response{status_code: status} = response} ->
            if status in expected_status do
              Logger.debug "[FleetApi] request to #{url} succeeded with status code #{inspect status}"
              if String.length(response.body) != 0 && parse_response do
                {:ok, Poison.decode!(response.body)}
              else
                {:ok, response}
              end
            else
              Logger.error "[FleetApi] request to #{url} returned status code #{inspect status}"
              {:error, %{reason: "Expected response status in #{inspect expected_status} but got #{status}."}}
            end
          error ->
            Logger.error "[FleetApi] request to #{url} did not complete. Error: #{inspect error}."
            error
        end
      end
    end
  end
end