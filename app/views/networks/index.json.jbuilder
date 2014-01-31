json.array!(@networks) do |network|
  json.extract! network, :id, :name, :ip_four
  json.url network_url(network, format: :json)
end
