defmodule Alumni.CohortResolver do
  import Ecto.Query
  alias Alumni.{Cohort, Repo}

  def find(%{id: id}, args, info) do
    query =
      from c in Cohort,
        where: c.campus_id == ^id

    {:ok, Repo.all(query)}
  end

  def all(_args, _info) do
    {:ok, Repo.all(Cohort)}
  end

  def create(args, _info) do
    %Cohort{}
    |> Cohort.changeset(args)
    |> Repo.insert
  end
end
