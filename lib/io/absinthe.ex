defmodule Plsm.IO.Absinthe do

    @doc """
      Generate the schema field based on the database type
    """
    def type_output (field) do
        case field do
            {name, type} when type == :integer -> four_space "field :#{name}, :integer\n"
            {name, type} when type == :decimal -> four_space "field :#{name}, :decimal\n"
            {name, type} when type == :float -> four_space  "field :#{name}, :float\n"
            {name, type} when type == :string -> four_space "field :#{name}, :string\n"
            {name,type} when type == :date -> four_space "field :#{name}, :datetime\n"
            _ -> ""
        end
    end

  @doc """
    Write the given schema to file.
  """
  @spec write(String.t, String.t, String.t) :: Any
  def write(schema, name, path \\ "") do
    unless File.dir?(path) do
      File.mkdir!(path)
    end
    case File.open "#{path}#{name}.ex", [:write] do
      {:ok, file} -> IO.puts "#{path}#{name}.ex"; IO.binwrite file, schema
      {_, msg} -> IO.puts "Could not write #{name} to file: #{msg}"
    end
  end
    
  @doc """
  Format the text of a specific table with the fields that are passed in. This is strictly formatting and will not verify the fields with the database
  """
  @spec prepare(Plsm.Database.Table, String.t) :: {Plsm.Database.TableHeader, String.t}
  def prepare(table, project_name) do
      output = module_declaration(project_name,table.header.name) <> model_inclusion() <> schema_declaration(table.header.name)
      trimmed_columns = remove_foreign_keys(table.columns)
      column_output = trimmed_columns |> Enum.reduce("",fn(x,a) -> a <> type_output({x.name, x.type}) end)
      output = output <> column_output
      output = output <> two_space(end_declaration())
      output = output <> end_declaration()
      {table.header, output}
  end

  defp module_declaration(project_name, table_name) do
    namespace = Plsm.Database.TableHeader.table_name(table_name)
    "defmodule #{project_name}.Types.#{namespace} do\n"
  end

  defp model_inclusion do
    two_space "use Absinthe.Schema.Notation\n\n"
  end

  defp schema_declaration(table_name) do
    two_space "object \"#{table_name}\" do\n"
  end

  defp end_declaration do
    "end\n"
  end

  defp four_space(text) do
    "    " <> text
  end

  defp two_space(text) do
    "  " <> text
  end

  defp remove_foreign_keys(columns) do
    Enum.filter(columns, fn(column) ->
      column.foreign_table == nil and column.foreign_field == nil
    end)
  end
end