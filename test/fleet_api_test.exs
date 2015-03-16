defmodule FleetApiTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import FleetApi

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end

  test "list_units" do
    use_cassette "list_units", custom: true do
      {result, units} = list_units("http://54.85.141.240:7002")
      
      assert result == :ok
    end
  end

  test "get_unit" do
    use_cassette "get_unit", custom: true do
      {result, units} = get_unit("http://54.85.141.240:7002", "subgun-http.service")
      
      assert result == :ok
    end
  end

  test "delete_unit" do
    use_cassette "delete_unit", custom: true do
      assert :ok = delete_unit("http://54.85.141.240:7002", "subgun-http.service")
    end
  end
end
