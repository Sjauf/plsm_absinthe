defmodule Plsm.IO.Graphql do

    def write_types_file(project_name, types, path \\ "") do
        output = prepare_types_file(project_name, types)
        File.write!(path, output)
    end

    def prepare_types_file(project_name, types) do
        output = "defmodule " <> project_name <> " do \n"
        output = output <> four_space("use Absinthe.Schema.Notation\n\n")
        output_types = Enum.reduce(types, "", fn type, str -> str <> four_space("import_types " <> type <> "\n") end)
        output = output <> output_types
        output = output <> "\n"
        output = output <> end_declaration
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

    def prepare_queries(types) do
        
    end

    def prepare_mutations(types) do
        
    end

    def prepare_schema(mutations) do
        
    end
end