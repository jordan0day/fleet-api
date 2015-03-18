defmodule FleetApi.Api do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use FleetApi.Request
      alias FleetApi.Unit
      alias FleetApi.UnitOption
      alias FleetApi.UnitState
      alias FleetApi.Machine
      alias FleetApi.Error

      defp add_query_param(url, name, value) do
        separator = if String.contains?(url, "?"), do: "&", else: "?"

        url <> separator <> name <> "=" <> value
      end

      defp paginated_request(method, url, headers, body, expected_status \\ [200], resp_bodies \\ [], next_page_token \\ "") do
        request_url = if next_page_token == "" do
          url
        else
          add_query_param(url, "nextPageToken", next_page_token)
        end

        case request(method, request_url, headers, body, expected_status) do
          {:ok, %{"nextPageToken" => token} = resp_body} ->
            paginated_request(method, url, headers, body, expected_status, [resp_body | resp_bodies], token)
          {:ok, resp_body} ->
            result = [resp_body | resp_bodies]
                     |> Enum.reverse
            
            {:ok, result}
          error -> error
        end
      end

      
      @spec api_list_units(String.t) :: {:ok, [FleetApi.Unit.t]} | {:error, any}
      defp api_list_units(node_url) do
        case paginated_request(:get, node_url <> "/fleet/v1/units", [], "") do
          {:ok, resp_bodies} ->
            units = resp_bodies
                    |> Enum.flat_map(fn resp -> resp["units"] end)
                    |> Enum.filter(fn unit -> unit != nil end)
                    |> Enum.map(&Unit.from_map/1)
            {:ok, units}
          other -> other
        end
      end

      
      @spec api_get_unit(String.t, String.t) :: {:ok, FleetApi.Unit.t} | {:error, any}
      defp api_get_unit(node_url, unit_name) do
        case request(:get, node_url <> "/fleet/v1/units/" <> unit_name, [], "") do
          {:ok, resp_body} ->
            unit = resp_body
                   |> Unit.from_map
            {:ok, unit}
          other -> other
        end
      end

      
      @spec api_delete_unit(String.t, String.t) :: :ok | {:error, any}
      defp api_delete_unit(node_url, unit_name) do
       case request(:delete, node_url <> "/fleet/v1/units/" <> unit_name, [], "", [204]) do
          {:ok, _} -> :ok
          other -> other
        end
      end

      
      @spec api_set_unit(String.t, String.t, FleetApi.Unit.t) :: :ok | {:error, any}
      defp api_set_unit(node_url, unit_name, unit) do
        case request(:put, node_url <> "/fleet/v1/units/" <> unit_name, [{"Content-Type", "application/json"}], Poison.encode!(unit), [201, 204]) do
          {:ok, _} -> :ok
          other -> other
        end
      end

      
      @spec api_list_unit_states(String.t, [{atom, String.t}]) :: {:ok, [FleetApi.UnitState.t]} | {:error, any}
      defp api_list_unit_states(node_url, opts \\ []) do
        url = node_url <> "/fleet/v1/state"
        machine_id = Keyword.get(opts, :machine_id)
        unit_name = Keyword.get(opts, :unit_name)

        url = cond do
          machine_id && unit_name -> url <> "?machineID=" <> machine_id <> "&unitName=" <> unit_name
          machine_id -> url <> "?machineID=" <> machine_id
          unit_name -> url <> "?unitName=" <> unit_name
          true -> url
        end

        case paginated_request(:get, url, [], "") do
          {:ok, resp_bodies} ->
            states = resp_bodies
                     |> Enum.flat_map(fn resp -> resp["states"] end)
                     |> Enum.map(&UnitState.from_map/1)
            {:ok, states}
          other -> other
        end
      end

      
      @spec api_list_machines(String.t) :: {:ok, [FleetApi.Machine.t]} | {:error, any}
      defp api_list_machines(node_url) do
        case paginated_request(:get, node_url <> "/fleet/v1/machines", [], "") do
          {:ok, resp_bodies} ->
            machines = resp_bodies
                       |> Enum.flat_map(fn resp -> resp["machines"] end)
                       |> Enum.map(&Machine.from_map/1)

            {:ok, machines}
          other -> other
        end
      end

      @spec api_discovery(String.t) :: {:ok, Map.t} | {:error, any}
      defp api_discovery(node_url) do
        case request(:get, node_url <> "/fleet/v1/discovery") do
          {:ok, discovery} -> {:ok, discovery}
          other -> other
        end
      end
    end
  end  
end