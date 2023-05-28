defmodule GraphGenerator do

  def create_adjacency_matrix(num_vertices, oriented, weighted) do
    matrix = Enum.map(1..num_vertices, fn _ ->
      Enum.map(1..num_vertices, fn _ -> 0 end)
    end)
    create_adjacency_matrix(num_vertices, matrix, 0, 1, oriented, weighted)
  end

  def get_weight(weighted) do
    if weighted do
      weight = :rand.uniform(100)+1 # max weight
      weight
    else
      weight = 1
      weight
    end
  end

  def get_new_matrix(matrix, i, j, weight, oriented) do
    if oriented do
      matrix = set_weight(matrix, i, j, weight)
      matrix
    else
      matrix = set_weight(matrix, i, j, weight)
      matrix = set_weight(matrix, j, i, weight)
      matrix
    end
  end

  def create_adjacency_matrix(num_vertices, matrix, i, j, oriented, weighted) when i < num_vertices and j < num_vertices do
    weight = get_weight(weighted)
    matrix = get_new_matrix(matrix, i, j, weight, oriented)
    if j < num_vertices - 1 do
      create_adjacency_matrix(num_vertices, matrix, i, j + 1, oriented, weighted) # пока не уперлись вправо
    else
      create_adjacency_matrix(num_vertices, matrix, i + 1, i + 2, oriented, weighted) # смещение вниз и + 2 от диагонали
    end
  end

  def create_adjacency_matrix(_, matrix, _, _, _, _), do: matrix # ~ stop-return для рекурсии

  def set_weight(matrix, i, j, weight) do
    List.replace_at(matrix, i, List.replace_at(Enum.at(matrix, i), j, weight))
  end


  def calc_edges_count(matrix, oriented) do
    if oriented do
      nz = calc_edges_count(matrix)
      nz
    else
      nz = div(calc_edges_count(matrix), 2)
      nz
    end
  end

  def calc_edges_count(matrix) do
    Enum.reduce(matrix, 0, fn row, acc ->
      acc + Enum.count(row, &(&1 != 0))
    end)
  end

  def clamp_vertex_count(vertex_count) do
    if vertex_count < 3 do
      3
    else
      if vertex_count > 7 do
        7
      else
        vertex_count
      end
    end
  end

  def clamp_delete_count(delete_count) do
    if delete_count < 1 do
      1
    else
      if delete_count > 13 do
        13
      else
        delete_count
      end
    end
  end

  def get_coords_to_del_x(id, vertex_count) do
    vertex_count = clamp_vertex_count(vertex_count)
    x_3 = [1]
    x_4 = [1,1,2]
    x_5 = [1,1,1,2,2,3]
    x_6 = [1,1,1,1,2,2,2,3,3,4]
    x_7 = [1,1,1,1,1,2,2,2,2,3,3,3,4,4,5]
    if vertex_count == 3 do
      Enum.at(x_3, id)
    else
      if vertex_count == 4 do
        Enum.at(x_4, id)
      else
        if vertex_count == 5 do
          Enum.at(x_5, id)
        else
          if vertex_count == 6 do
            Enum.at(x_6, id)
          else
            if vertex_count == 7 do
              Enum.at(x_7, id)
            end
          end
        end
      end
    end
  end

  def get_coords_to_del_y(id, vertex_count) do
    vertex_count = clamp_vertex_count(vertex_count)
    y_3 = [2]
    y_4 = [2,3,3]
    y_5 = [2,3,4,3,4,4]
    y_6 = [2,3,4,5,3,4,5,4,5,5]
    y_7 = [2,3,4,5,6,3,4,5,6,4,5,6,5,6,6]
    if vertex_count == 3 do
      z = Enum.at(y_3, id)
      z
    else
      if vertex_count == 4 do
        z = Enum.at(y_4, id)
        z
      else
        if vertex_count == 5 do
          z = Enum.at(y_5, id)
          z
        else
          if vertex_count == 6 do
            z = Enum.at(y_6, id)
            z
          else
            if vertex_count == 7 do
              z = Enum.at(y_7, id)
              z
            end
          end
        end
      end
    end
  end

  def rem_neg_del_count(del_count) do
    if del_count < 0 do
      0
    else
      del_count
    end
  end

  def del_edges(matrix, vertex_count, edges_count, oriented) do
    if vertex_count > 2 and vertex_count < 8 and edges_count >= div(vertex_count*(vertex_count-1), 2) - (vertex_count-1) do
      to_delete = calc_edges_count(matrix, oriented) - edges_count
      to_delete = rem_neg_del_count(to_delete)
      id = 0
      matrix = del_edges(matrix, vertex_count, to_delete, oriented, id)
      matrix
    else
      target_edges_count = :rand.uniform(vertex_count)-1+vertex_count
      to_delete = calc_edges_count(matrix, oriented) - target_edges_count
      to_delete = clamp_delete_count(to_delete)
      id = 0
      matrix = del_edges(matrix, vertex_count, to_delete, oriented, id)
      matrix
    end
  end

  def del_edges(matrix, vertex_count, to_delete, oriented, id) do
    if to_delete == 0 do
      matrix
    else
      x = get_coords_to_del_x(id, vertex_count)
      y = get_coords_to_del_y(id, vertex_count)
      if oriented do
        matrix = set_weight(matrix, x, y, 0)
        del_edges(matrix, vertex_count, to_delete-1, oriented, id+1)
      else
        matrix = set_weight(matrix, x, y, 0)
        matrix = set_weight(matrix, y, x, 0)
        del_edges(matrix, vertex_count, to_delete-1, oriented, id+1)
      end
    end
  end


  def generate(num_vertexes, edges_count, weighted, oriented) do
    adjacency_matrix = create_adjacency_matrix(num_vertexes, oriented, weighted)
    res = del_edges(adjacency_matrix, num_vertexes, edges_count, oriented)
    ec = calc_edges_count(res, oriented)
    IO.inspect(ec)
    res
  end

end

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


weighted = true
oriented = true
num_vertexes = String.to_integer(Enum.at(System.argv(), 0))
edges_count = 10000


adjacency_matrix = GraphGenerator.generate(num_vertexes, edges_count, weighted, oriented)
FileUtils.write_matrix(adjacency_matrix, 'data/matrix_#{num_vertexes}.txt')