defmodule FastGlobalBench do
  use Benchfella

  bench "fastglobal put (5)", [data: gen_services(5)] do
    FastGlobal.put(:data, data)
    :ok
  end

  bench "fastglobal put (10)", [data: gen_services(10)] do
    FastGlobal.put(:data, data)
    :ok
  end

  bench "fastglobal put (100)", [data: gen_services(100)] do
    FastGlobal.put(:data, data)
    :ok
  end

  bench "fastglobal get", [fastglobal: gen_fastglobal()] do
    FastGlobal.get(fastglobal)
    :ok
  end

  bench "process", [agent: gen_agent()] do
    Agent.get(agent, &(&1))
    :ok
  end

  bench "ets", [ets: gen_ets()] do
    :ets.lookup(ets, :data)
    :ok
  end

  ## Private

  defp gen_fastglobal() do
    FastGlobal.put(:data, gen_services(10))
    :data
  end

  defp gen_agent() do
    {:ok, agent} = Agent.start_link(fn -> gen_services(10) end)
    agent
  end

  defp gen_ets() do
    tab = :ets.new(:data, [:public, {:read_concurrency, true}])
    :ets.insert(tab, {:data, gen_services(10)})
    tab
  end

  defp gen_services(n) do
    for i <- 0..n, into: Map.new do
      service = new_service(i)
      {service.id, service}
    end
  end

  defp new_service(i) do
    port = 3000 + i
    %{
      __struct__: FastGlobal.Service,
      address: "fast-global-prd-1-#{i}",
      id: "fast-global-prd-1-#{i}:#{port}",
      metadata: %{
        "otp" => "discord_guilds@discord-guilds-prd-1-#{i}",
        "capacity" => "low"
      },
      name: "discord_guilds",
      port: port
    }
  end
end
