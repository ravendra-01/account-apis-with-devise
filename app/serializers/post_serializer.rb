class PostSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :title, :description

  attribute :user do |object|
    object.user
  end
end
