json.array!(@dictionaries) do |dictionary|
  json.extract! dictionary, :id, :name
  json.url dictionary_url(dictionary, format: :json)
end
