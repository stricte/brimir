json.array!(@templates) do |template|
  json.extract! template, :id, :title, :description, :content
end
