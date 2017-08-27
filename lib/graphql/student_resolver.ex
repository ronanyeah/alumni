defmodule Alumni.StudentResolver do
  import Ecto.Query
  alias Alumni.{Student, Repo}

  def find(%{id: id}, args, info) do
    query =
      from c in Student,
        where: c.cohort_id == ^id

    {:ok, Repo.all(query)}
  end

  def all(_args, _info) do
    {:ok, Repo.all(Student)}
  end

  def create(args, _info) do
    %Student{}
    |> Student.changeset(args)
    |> Repo.insert
  end
end
