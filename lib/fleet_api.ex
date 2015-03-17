defmodule FleetApi do
  @moduledoc """
  This module contains functions for interacting with a Fleet API endpoint.
  """

  defmacro __using__(_) do
    quote do
      use Behaviour
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

      defp request(method, url, headers, body, expected_status \\ [200]) do
        options = case Application.get_env(:fleet_api, :proxy) do
          nil -> []
          proxy_opts -> [hackney: [proxy: proxy_opts]]
        end

        case HTTPoison.request(method, url, body, headers, options) do
          {:ok, %HTTPoison.Response{status_code: status} = response} when status in [400..599] ->
            if String.length(response.body) != 0 do
              error = response.body
                      |> Poison.decode!
                      |> Error.from_map
              {:error, error}
            else
              {:error, response}
            end
          {:ok, %HTTPoison.Response{status_code: status} = response} ->
            if status in expected_status do
              if String.length(response.body) != 0 do
                {:ok, Poison.decode!(response.body)}
              else
                {:ok, nil}
              end
            else
              {:error, "Expected response status #{expected_status} but got #{response.status_code}"}
            end
          error -> error
        end
      end

      @doc """
      Retrieve the list of units that the Fleet cluster currently knows about.
      """
      @spec list_units() :: {:ok, [FleetApi.Unit.t]}
      def list_units() do
        case paginated_request(:get, node_url <> "/fleet/v1/units", [], "") do
          {:ok, resp_bodies} ->
            units = resp_bodies
                    |> Enum.flat_map(fn resp -> resp["units"] end)
                    |> Enum.filter(fn unit -> unit != nil end)
                    |> Enum.map(&Unit.from_map/1)
            {:ok, units}
        end
      end

      @doc """
      Retrieve the details for a specific unit in the Fleet cluster.
      """
      @spec get_unit(String.t) :: {:ok, FleetApi.Unit.t}
      def get_unit(unit_name) do
        case request(:get, node_url <> "/fleet/v1/units/" <> unit_name, [], "") do
          {:ok, resp_body} ->
            unit = resp_body
                   |> Unit.from_map
            {:ok, unit}
        end
      end

      @doc """
      Remove a unit from the Fleet cluster.
      """
      @spec delete_unit(String.t) :: :ok
      def delete_unit(unit_name) do
       case request(:delete, node_url <> "/fleet/v1/units/" <> unit_name, [], "", [204]) do
          {:ok, _} -> :ok
        end
      end

      @doc """
      Adds or updates a unit in the Fleet cluster. If the cluster doesn't contain a
      unit with the given name, then a new unit is added to it. If a unit with the
      given name exists, it is updated with the new unit definition.
      """
      @spec set_unit(String.t, FleetApi.Unit.t) :: :ok
      def set_unit(unit_name, unit) do
        case request(:put, node_url <> "/fleet/v1/units/" <> unit_name, [{"Content-Type", "application/json"}], Poison.encode!(unit), [201, 204]) do
          {:ok, _} -> :ok
        end
      end

      @doc """
      Get the detailed state information for all the units in the Fleet cluster.
      """
      @spec list_unit_states([{atom, String.t}]) :: {:ok, [FleetApi.UnitState.t]}
      def list_unit_states(opts \\ []) do
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
        end
      end

      @doc """
      Retrieve the list of nodes currently in the Fleet cluster.
      """
      @spec list_machines() :: {:ok, [FleetApi.Machine.t]}
      def list_machines() do
        case paginated_request(:get, node_url <> "/fleet/v1/machines", [], "") do
          {:ok, resp_bodies} ->
            machines = resp_bodies
                       |> Enum.flat_map(fn resp -> resp["machines"] end)
                       |> Enum.map(&Machine.from_map/1)

            {:ok, machines}
        end
      end

      @doc "Retrieves the Fleet API node URL, based on either etcd discovery or direct setting of the node url."
      defcallback node_url() :: String.t

      defoverridable [list_units: 0, get_unit: 1, delete_unit: 1, set_unit: 2, list_unit_states: 1, list_machines: 0]
    end
  end
end
