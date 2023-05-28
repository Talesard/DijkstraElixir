defmodule FileUtils do
  def write_matrix(matrix, file_path) do
    File.write(file_path, matrix_to_string(matrix))
  end

  defp matrix_to_string(matrix) do
    matrix
    |> Enum.map(&row_to_string(&1))
    |> Enum.join("\n")
  end

  defp row_to_string(row) do
    row
    |> Enum.map(&to_string/1)
    |> Enum.join(" ")
  end

  def read_matrix(file_path) do
    case File.read(file_path) do
      {:ok, content} -> string_to_matrix(content)
      {:error, reason} -> {:error, reason}
    end
  end

  defp string_to_matrix(content) do
    content
    |> String.split("\n", trim: true)
    |> Enum.map(&string_to_row/1)
  end
  
  defp string_to_row(row_str) do
    row_str
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end


defmodule Dijkstra do
  @inf 999999
  
  def run_dijkstra(matrix, start_vertex, stop_vertex) do
    {opt_conns, labels} = get_opt_connections(matrix, start_vertex, stop_vertex)
    path = restore_path(opt_conns, start_vertex, stop_vertex)
    {path, opt_conns, labels}
  end

  defp get_opt_connections(matrix, start_vertex, stop_vertex) do
    vertex_count = length(matrix)
    labels = initialize_labels(vertex_count, start_vertex)
    visited = [:false | _] = List.duplicate(false, vertex_count)

    current_vertex = get_next_vertex(labels, visited)
    opt_conns = Enum.map(0..(vertex_count - 1), fn _ -> 0 end)
    opt_conns_final = main_loop(matrix, labels, visited, current_vertex, opt_conns)
    opt_conns_final
  end

  defp main_loop(matrix, labels, visited, current_vertex, opt_conns) do
    if check_all_visited(visited) do # если все посещены, то выходим
      {opt_conns, labels}
    else # продолжаем поиск
      # отмечаем, что текущая вершина посещена
      visited = List.replace_at(visited, current_vertex, true)
      # ищем непосещенных соседей
      neighbors = get_neighbors(matrix, current_vertex, visited)
      # обновляем метки соседей
      {labels, opt_conns} = update_labels(matrix, labels, neighbors, current_vertex, opt_conns)
      # ищем новую вершину для исследования
      current_vertex = get_next_vertex(labels, visited)
      if current_vertex == nil do
        {opt_conns, labels}
      else
        main_loop(matrix, labels, visited, current_vertex, opt_conns)
      end
    end
  end
  
  # проверка, что все вершины посещены
  defp check_all_visited(visited) do
    all_true = Enum.all?(visited, fn x -> x == true end)
    all_true
  end

  # тут обновляем метки
  # если метка уменьшилась, то сохраняем
  defp update_labels(matrix, labels, neighbors, current_vertex, opt_conns) do
    if length(neighbors) == 0 do # если обошли всех соседей
      {labels, opt_conns}
    else
      current_neighbor = hd(neighbors) # голова
      rem_neighbors = tl(neighbors) # хвост
    #   IO.inspect(rem_neighbors)
      v = elem(current_neighbor, 1) # вершина
      w = elem(current_neighbor, 0) # вес
      if Enum.at(labels, current_vertex) + w < Enum.at(labels, v) do # если улучшили
        new_labels = List.replace_at(labels, v, Enum.at(labels, current_vertex) + w) # обновляем метку
        new_conns = List.replace_at(opt_conns, v, current_vertex)
        update_labels(matrix, new_labels, rem_neighbors, current_vertex, new_conns)
      else
        update_labels(matrix, labels, rem_neighbors, current_vertex, opt_conns)
      end
    end
  end

  # тут нужно найти всех непосещенных соседей (через 1 ребро) от текущей
  # возвращает список [{вес, айди}, {},...,{}]
  defp get_neighbors(matrix, current_vertex, visited) do
    distances = Enum.at(matrix, current_vertex) # нужная строка матрицы
    pairs = Enum.with_index(distances) # пары с айдишниками
    unvisited = Enum.filter(pairs, fn {d, id} -> Enum.at(visited, id) == false end) # нашли непосещенные пары
    result = Enum.filter(unvisited, fn {d, id} -> d != 0 end) # убрали несуществующие пути
    result
  end

  defp initialize_labels(vertex_count, start_vertex) do
    Enum.map(0..(vertex_count - 1), fn vertex ->
      if vertex == start_vertex, do: 0, else: @inf
    end)
  end
  
  # тут нужно найти непосещенную вершину с минимальной меткой
  defp get_next_vertex(labels, visited) do
    pairs = Enum.with_index(labels)
    not_visited = Enum.filter(pairs, fn {_, index} -> Enum.at(visited, index) != true end)
    if length(not_visited) == 0 do
      nil
    else
      min_not_visited = Enum.min_by(not_visited, fn {labels, _} -> labels end)
      next_vertex = elem(min_not_visited, 1)
      next_vertex
    end
  end

  defp restore_path(opt_conns, v_start, v_end) do
    path = restore_path_recurs(opt_conns, v_start, v_end, [v_end])
  end
  
  defp restore_path_recurs(opt_conns, v_start, v_curr, path) do
    if v_start == v_curr do
      path
    else
      v_curr = Enum.at(opt_conns, v_curr)
      path = [v_curr | path]
      restore_path_recurs(opt_conns, v_start, v_curr, path)
    end
  end

end


# adjacency_matrix = [
#   [0, 48, 42, 11, 55],
#   [0, 0, 0, 0, 40],
#   [0, 0, 0, 37, 39],
#   [0, 0, 0, 0, 42],
#   [0, 0, 0, 0, 0]
# ]


num_vertexes = String.to_integer(Enum.at(System.argv(), 0))
file = 'data/matrix_#{num_vertexes}.txt'
adjacency_matrix = FileUtils.read_matrix(file)
# IO.inspect(adjacency_matrix)
v_start = 0
v_end = length(adjacency_matrix)-1
{path, opt_conns, labels} = Dijkstra.run_dijkstra(adjacency_matrix, v_start, v_end)

IO.puts('\nPath:')
IO.inspect(path)

# IO.puts('\nOpt connections:')
# IO.inspect(opt_conns)

# IO.puts('\nLabels:')
# IO.inspect(labels)

# IO.puts('\nCriteria value:')
# IO.inspect(Enum.at(labels, v_end))