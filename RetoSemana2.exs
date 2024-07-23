defmodule Library do
  defmodule Book do
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    defstruct name: "", id: "", borrowed_books: []
  end

  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: true}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def list_books(library) do
    library
  end

  def list_users(users) do
    users
  end

  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end

  def main do
    library = []
    users = []

    loop(library, users)
  end

  defp loop(library, users) do
    IO.puts """
    Elija una opción:
    1. Agregar libro
    2. Agregar usuario
    3. Prestar libro
    4. Devolver libro
    5. Listar libros
    6. Listar usuarios
    7. Listar libros prestados a un usuario
    8. Salir
    """

    option = IO.gets("Opción: ") |> String.trim() |> String.to_integer()

    {library, users} = case option do
      1 ->
        title = IO.gets("Título del libro: ") |> String.trim()
        author = IO.gets("Autor del libro: ") |> String.trim()
        isbn = IO.gets("ISBN del libro: ") |> String.trim()
        book = %Book{title: title, author: author, isbn: isbn}
        {add_book(library, book), users}

      2 ->
        name = IO.gets("Nombre del usuario: ") |> String.trim()
        id = IO.gets("ID del usuario: ") |> String.trim()
        user = %User{name: name, id: id}
        {library, add_user(users, user)}

      3 ->
        user_id = IO.gets("ID del usuario: ") |> String.trim()
        isbn = IO.gets("ISBN del libro a prestar: ") |> String.trim()
        case borrow_book(library, users, user_id, isbn) do
          {:ok, new_library, new_users} ->
            IO.puts("Libro prestado exitosamente.")
            {new_library, new_users}
          {:error, reason} ->
            IO.puts("Error: #{reason}")
            {library, users}
        end

      4 ->
        user_id = IO.gets("ID del usuario: ") |> String.trim()
        isbn = IO.gets("ISBN del libro a devolver: ") |> String.trim()
        case return_book(library, users, user_id, isbn) do
          {:ok, new_library, new_users} ->
            IO.puts("Libro devuelto exitosamente.")
            {new_library, new_users}
          {:error, reason} ->
            IO.puts("Error: #{reason}")
            {library, users}
        end

      5 ->
        IO.inspect(list_books(library))
        {library, users}

      6 ->
        IO.inspect(list_users(users))
        {library, users}

      7 ->
        user_id = IO.gets("ID del usuario: ") |> String.trim()
        IO.inspect(books_borrowed_by_user(users, user_id))
        {library, users}

      8 ->
        IO.puts("Saliendo...")
        :init.stop()

      _ ->
        IO.puts("Opción no válida.")
        {library, users}
    end

    loop(library, users)
  end
end

Library.main()
