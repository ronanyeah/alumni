defmodule Alumni.CampusResolver do
  alias Alumni.{Campus, Repo}

  def all(_args, _info) do
    {:ok, Repo.all(Campus)}
  end

  def find(%{id: id}, _info) do
    case Repo.get(Campus, id) do
      nil  -> {:error, "Campus id #{id} not found"}
      campus -> {:ok, campus}
    end
  end
end
