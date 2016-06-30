json.array!(@acronyms) do |acronym|
  json.extract! acronym, :id, :acronym, :context, :bracketed, :bracketed_on_first_use
  json.url acronym_url(acronym, format: :json)
end
