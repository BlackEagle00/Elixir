defmodule Juego do
  @direcciones [:arriba, :abajo, :izquierda, :derecha]

  def iniciar do
    controlador_pid = spawn(__MODULE__, :controlador, [])
    spawn(__MODULE__, :jugador, [{0, 0}, controlador_pid])
  end

  def jugador(posicion, controlador_pid) do
    nueva_posicion = mover(posicion)
    send(controlador_pid, {:posicion, nueva_posicion})
    :timer.sleep(1000)
    jugador(nueva_posicion, controlador_pid)
  end

  def controlador do
    receive do
      {:posicion, {x, y}} ->
        IO.puts("Jugador está en posición: (#{x}, #{y})")
        controlador()
    end
  end

  defp mover({x, y}) do
    direccion = Enum.random(@direcciones)
    case direccion do
      :arriba -> {x, y + 1}
      :abajo -> {x, y - 1}
      :izquierda -> {x - 1, y}
      :derecha -> {x + 1, y}
    end
  end
end

# Para iniciar el juego, ejecuta en el shell de Elixir:
# Juego.start()
