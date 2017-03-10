json.array!(@definitions) do |definition|
  json.extract! definition, :id, :dictionary_id, :initialism
  json.url definition_url(definition, format: :json)
end
