# Trabajo Autónomo - Reto Semana 1 -  Andrés Guillermo Bonilla Olarte

defmodule InventoryManager do
  defstruct inventory: [], cart: []

  # Función de añadir producto
  def add_product(inventory_manager) do
    name = IO.gets("Nombre del producto: ") |> String.trim()
    price = IO.gets("Precio del producto: ") |> String.trim() |> String.to_float()
    stock = IO.gets("Stock del producto: ") |> String.trim() |> String.to_integer()

    id = length(inventory_manager.inventory) + 1

    product = %{id: id, name: name, price: price, stock: stock}
    new_inventory = [product | inventory_manager.inventory]

    %{inventory_manager | inventory: new_inventory}
  end

  # Función de listar productos
  def list_products(inventory_manager) do
    IO.puts("Productos en el inventario: ")
    Enum.each(inventory_manager.inventory, fn product ->
      IO.puts("ID: #{product.id}. Nombre: #{product.name}, Precio: #{product.price}, Stock: #{product.stock}")
    end)
  end

  # Función de añadir stock
  def increase_stock(inventory_manager) do
    id = IO.gets("ID del producto: ") |> String.trim() |> String.to_integer()
    quantity = IO.gets("Cantidad a aumentar: ") |> String.trim() |> String.to_integer()

    new_inventory = Enum.map(inventory_manager.inventory, fn product ->
      if product.id == id do
        %{product | stock: product.stock + quantity}
      else
        product
      end
    end)

    %{inventory_manager | inventory: new_inventory}
  end

  # Función de vender productos
  def sell_product(inventory_manager) do
    id = IO.gets("ID del producto: ") |> String.trim() |> String.to_integer()
    quantity = IO.gets("Cantidad a vender: ") |> String.trim() |> String.to_integer()

    product = Enum.find(inventory_manager.inventory, fn p -> p.id == id end)

    if product && product.stock >= quantity do
      updated_product = %{product | stock: product.stock - quantity}
      updated_inventory = Enum.map(inventory_manager.inventory, fn p ->
        if p.id == id, do: updated_product, else: p
      end)

      cart_item = {id, quantity}
      new_cart = [cart_item | inventory_manager.cart]

      {:ok, %{inventory_manager | inventory: updated_inventory, cart: new_cart}}
    else
      {:error, "Stock insuficiente o producto no encontrado."}
    end
  end

  # Función de ver productos en el carrito
  def view_cart(inventory_manager) do
    IO.puts("Productos en el carrito: ")
    total = Enum.reduce(inventory_manager.cart, 0, fn {id, quantity}, acc ->
      product_price = Enum.find(inventory_manager.inventory, fn p -> p.id == id end).price
      IO.puts("ID: #{id}, Cantidad: #{quantity}, Precio Total: #{product_price * quantity}")
      acc + (product_price * quantity)
    end)
    IO.puts("Costo total: #{total}")
  end

  # Función de cobro de productos
  def checkout(inventory_manager) do
    IO.puts("Realizando cobro de productos...")
    IO.puts("Su carrito ha sido vaciado.")
    %{inventory_manager | cart: []}
  end

  # Función de ejecución de bucle para interacción con el usuario
  def run do
    inventory_manager = %InventoryManager{}
    loop(inventory_manager)
  end

  # Interacción con el usuario
  defp loop(inventory_manager) do
    IO.puts("""
    Gestor de productos
    1. Agregar producto al inventario
    2. Listar productos
    3. Aumentar stock de producto existente
    4. Vender producto
    5. Mostrar productos del carrito
    6. Realizar cobro de productos
    0. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("Opción: ") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        inventory_manager = add_product(inventory_manager)
        loop(inventory_manager)

      2 ->
        list_products(inventory_manager)
        loop(inventory_manager)

      3 ->
        inventory_manager = increase_stock(inventory_manager)
        loop(inventory_manager)

      4 ->
        case sell_product(inventory_manager) do
          {:ok, updated_manager} -> loop(updated_manager)
          {:error, message} ->
            IO.puts(message)
            loop(inventory_manager)
        end

      5 ->
        view_cart(inventory_manager)
        loop(inventory_manager)

      6 ->
        inventory_manager = checkout(inventory_manager)
        loop(inventory_manager)

      0 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(inventory_manager)
    end
  end
end

# Ejecutar el gestor de productos
InventoryManager.run()
