defmodule FleetApi do
  defmodule UnitOption do
    defstruct section: nil, name: nil, value: nil

    def from_map(option_map) do
      %UnitOption{
        section: option_map["section"],
        name: option_map["name"],
        value: option_map["value"]
      }
    end
  end

  defmodule Unit do
    defstruct name: nil, options: [], desiredState: nil, currentState: nil, machineID: nil

    def from_map(unit_map) do
      %Unit{
        name: unit_map["name"],
        options: unit_map["options"] |> Enum.map(&UnitOption.from_map/1),
        desiredState: unit_map["desiredState"],
        currentState: unit_map["currentState"],
        machineID: unit_map["machineID"]
      }
    end
  end

  defmodule UnitState do
    defstruct name: nil, hash: nil, machineID: nil, systemdLoadState: nil, systemdActiveState: nil, systemdSubState: nil

    def from_map(state_map) do
      %UnitState{
        name: state_map["name"],
        hash: state_map["hash"],
        machineID: state_map["machineID"],
        systemdLoadState: state_map["systemdLoadState"],
        systemdActiveState: state_map["systemdActiveState"],
        systemdSubState: state_map["systemdSubState"]
      }

    end
  end

  defmodule Machine do
    defstruct id: nil, primaryIP: nil, metadata: nil

    def from_map(machine_map) do
      %Machine{
        id: machine_map["id"],
        primaryIP: machine_map["primaryIP"],
        metadata: machine_map["metadata"]
      }
    end
  end

  defmodule Error do
    defstruct code: nil, message: nil

    def from_map(error_map) do
      %Error{
        code: error_map["code"],
        message: error_map["message"]
      }
    end
  end

  defp add_query_param(url, name, value) do
    separator = if String.contains?(url, "?"), do: "&", else: "?"

    url <> separator <> name <> "=" <> value
  end

  defp paginated_request(method, url, headers, body, expected_status \\ 200, resp_bodies \\ [], next_page_token \\ "") do
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

  defp request(method, url, headers, body, expected_status \\ 200) do
    options = case Application.get_env(:fleet_api, :proxy) do
      nil -> []
      proxy_opts -> [hackney: [proxy: proxy_opts]]
    end

    case HTTPoison.request(method, url, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: ^expected_status} = response} ->
        if String.length(response.body) != 0 do
          {:ok, Poison.decode!(response.body)}
        else
          {:ok, nil}
        end
      {:ok, %HTTPoison.Response{status_code: status} = response} when status in [400..599] ->
        if String.length(response.body) != 0 do
          error = response.body
                  |> Poison.decode!
                  |> Error.from_map
          {:error, error}
        else
          {:error, response}
        end
      {:ok, response} ->
        {:error, "Expected response status #{expected_status} but got #{response.status_code}"}
      error -> error
    end
  end

  def list_units(node_url) do
    case paginated_request(:get, node_url <> "/fleet/v1/units", [], "") do
      {:ok, resp_bodies} ->
        units = resp_bodies
                |> Enum.flat_map(fn resp -> resp["units"] end)
                |> Enum.filter(fn unit -> unit != nil end)
                |> Enum.map(&Unit.from_map/1)
        {:ok, units}
    end
  end

  def get_unit(node_url, unit_name) do
    case request(:get, node_url <> "/fleet/v1/units/" <> unit_name, [], "") do
      {:ok, resp_body} ->
        unit = resp_body
               |> Unit.from_map
        {:ok, unit}
    end
  end

  def delete_unit(node_url, unit_name) do
   case request(:delete, node_url <> "/fleet/v1/units/" <> unit_name, [], "", 204) do
      {:ok, _} -> :ok
    end
  end

  def create_unit(node_url, unit_name, unit) do
    case request(:put, node_url <> "/fleet/v1/units/" <> unit_name, [{"Content-Type", "application/json"}], Poison.encode!(unit), 201) do
      {:ok, _} -> :ok
    end
  end

  def update_unit_desired_state(node_url, unit_name, desired_state) do
    case request(:put, node_url <> "/fleet/v1/units/" <> unit_name, [{"Content-Type", "application/json"}], "{\"desiredState\":\"#{desired_state}\"", 204) do
      {:ok, _} -> :ok
    end
  end

  def list_unit_states(node_url, opts \\ []) do
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

  def list_machines(node_url) do
    case paginated_request(:get, node_url <> "/fleet/v1/machines", [], "") do
      {:ok, resp_bodies} ->
        machines = resp_bodies
                   |> Enum.flat_map(fn resp -> resp["machines"] end)
                   |> Enum.map(&Machine.from_map/1)

        {:ok, machines}
    end
  end
end
