defmodule Issues.TableFormatter do
  def print_table_for_columns([], _) do
    IO.puts("empty")
  end

  @doc """
  표의 각 행이 될 맵의 리스트와 헤더의 리스트를 받아,
  각 행에서 헤더를 기준으로 데이터를 식별해 표준 출력(STDOUT)으로 표를 표시한다.
  즉 각 헤더는 표의 열이 되며, 이를 이용해 각 행에서 필드의 값을 추출해 출력한다.  
  
  각 열의 가로 길이는 해당 열의 가장 긴 값에 맞도록 계산한다.
  """
  def print_table_for_columns(rows, headers) do
    with data_by_columns = split_into_columns(rows, headers),
         column_widths = widths_of(data_by_columns),
         format = format_for(column_widths) do
      headers |> puts_one_line_in_columns(format)
      column_widths |> separator |> IO.puts()
      data_by_columns |> puts_in_columns(format)
    end
  end

  @doc """
  각 행이 키-값 쌍으로 이루어진 리스트일 때, 이 행의 리스트를 받아
  각 필드의 값만으로 이루어진 리스트를 반환한다.
  'header' 파라미터는 추출할 필드(열) 이름이 담긴 리스트다.
  
  ## 사용 예
    iex> list = [Enum.into([{"a", "1"}, {"b", "2"}, {"c", "3"}], %{}),
    ...>         Enum.into([{"a", "4"}, {"b", "5"}, {"c", "6"}], %{})]
    iex> Issues.TableFormatter.split_into_columns(list, [ "a", "b", "c" ])
    [ ["1", "4"], ["2", "5"], ["3", "6"] ]
  """
  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: to_string(row[header])
    end
  end

  @doc """
  데이터를 듬은 리스트를 포함하는 중첩 리스트를 받아,
  각 열의 최대 길이가 담긴 리스트를 반환한다.
  
  ## 사용 예
    iex> data = [["cat", "wombat", "elk"], ["mongoose", "ant", "gnu"]]
    iex> Issues.TableFormatter.widths_of(data)
    [6, 8]
  """
  def widths_of(columns) do
    for column <- columns, do: column |> Enum.map(&String.length/1) |> Enum.max()
  end

  @doc """
  숫자의 리스트를 받아, 표의 열을 나누는 포맷 문자열을 반환한다.
  각 열 사이에는 '" | "' 문자를 넣는다.
  
  ## 사용 예
    iex> widths = [5, 6, 99]
    iex> Issues.TableFormatter.format_for(widths)
    "~-5s | ~-6s | ~-99s~n"
  """
  def format_for(column_widths) do
    Enum.map_join(column_widths, " | ", fn width -> "~-#{width}s" end) <> "~n"
  end

  @doc """
  표의 제목 행 아래에 구분선을 만든다.
  열 구분선과 같은 위치에는 + 기호, 그 외의 자리에는 - 기호를 사용한다.
  
  ## 사용 예
    iex> widths = [5, 6, 9]
    iex> Issues.TableFormatter.separator(widths)
    "------+--------+----------"
  """
  def separator(column_widths) do
    Enum.map_join(column_widths, "-+-", fn width -> List.duplicate("-", width) end)
  end

  @doc """
  데이터의 행으로 이루어진 리스트, 필드 리스트, 포맷 문자열을 받아   
  포맷 문자열의 형식으로 추출한 데이터를 출력한다.
  """
  def puts_in_columns(data_by_columns, format) do
    data_by_columns
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.each(&puts_one_line_in_columns(&1, format))
  end

  def puts_one_line_in_columns(field, format) do
    :io.format(format, field)
  end
end
