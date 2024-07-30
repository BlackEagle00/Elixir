#Mini proyecto entregable semana 3 - Andrés Guillermo Bonilla Olarte

defmodule Writer do
  alias Empresa.Employee

  @doc """
  Adds a new employee to the JSON file.
  """
  @spec add_employee(Employee.t(), String.t()) :: :ok
  def add_employee(employee = %Employee{}, filename \\ "employees.json") do
    employees = read_employees(filename)
    new_id = get_next_id(employees)
    updated_employee = Map.put(employee, :id, new_id)
    updated_employees = [updated_employee | employees]

    json_data = Jason.encode!(updated_employees, pretty: true)
    File.write(filename, json_data)
  end

  @doc """
  Deletes an employee by their ID from the JSON file.
  """
  @spec delete_employee(integer(), String.t()) :: :ok | {:error, :not_found}
  def delete_employee(id, filename \\ "employees.json") do
    employees = read_employees(filename)
    {employee, remaining_employees} = List.keytake(employees, id, :id)

    case employee do
      nil -> {:error, :not_found}
      _ ->
        json_data = Jason.encode!(remaining_employees, pretty: true)
        File.write(filename, json_data)
    end
  end

  @doc """
  Updates an employee's information in the JSON file.
  """
  @spec update_employee(Employee.t(), String.t()) :: :ok | {:error, :not_found}
  def update_employee(updated_employee = %Employee{id: id}, filename \\ "employees.json") do
    employees = read_employees(filename)
    {employee, remaining_employees} = List.keytake(employees, id, :id)

    case employee do
      nil -> {:error, :not_found}
      _ ->
        new_employees = [updated_employee | remaining_employees]
        json_data = Jason.encode!(new_employees, pretty: true)
        File.write(filename, json_data)
    end
  end

  @doc """
  Reads existing employees from the JSON file.
  """
  @spec read_employees(String.t()) :: [Employee.t()]
  defp read_employees(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        Jason.decode!(contents, keys: :atoms)
        |> Enum.map(&struct(Employee, &1))
      {:error, :enoent} -> []
    end
  end

  @doc """
  Generates the next available ID for a new employee.
  """
  @spec get_next_id([Employee.t()]) :: integer()
  defp get_next_id(employees) do
    employees
    |> Enum.map(& &1.id)
    |> Enum.max(fn -> 0 end)
    |> Kernel.+(1)
  end
end
