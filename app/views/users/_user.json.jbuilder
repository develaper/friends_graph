json.extract! user, :id, :friends_id, :created_at, :updated_at
json.url user_url(user, format: :json)
