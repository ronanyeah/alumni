defmodule Alumni.CohortResolver do
  alias Alumni.{Cohort, Repo}

  def all(_args, _info) do
    {:ok, Repo.all(Cohort)}
  end

  def create(args, _info) do
    %Cohort{}
    |> Cohort.changeset(args)
    |> Repo.insert
  end
end
