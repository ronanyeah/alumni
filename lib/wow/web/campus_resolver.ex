defmodule Wow.CampusResolver do
  alias Wow.{Campus, Repo}

  def all(_args, _info) do
    {:ok, Repo.all(Campus)}
  end
end
