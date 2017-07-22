defmodule Wow.CohortResolver do
  alias Wow.{Cohort, Repo}

  def all(_args, _info) do
    {:ok, Repo.all(Cohort)}
  end
end
