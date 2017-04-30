json.extract! pin, :id, :device_id, :name, :pin_type, :pin_number, :min, :max, :created_at, :updated_at
json.url pin_url(pin, format: :json)