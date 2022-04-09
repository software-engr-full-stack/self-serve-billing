require 'rails_helper'

describe 'the login process', type: :request do
  let(:email)    { 'user@example.com' }
  let(:name)     { 'user' }
  let(:password) { 'password' }

  it 'logs me in' do
    user = User.create!(email:, name:, password:)

    post api_v1_login_path, params: { user: { email:, password: } }

    got = json['user']
    expect(json['jwt']).not_to be_blank
    expect(got['id']).to eq user.id
    expect(got['email']).to eq email
    expect(got['name']).to eq name
  end
end

describe 'the sign up process', type: :request do
  let(:email)    { 'user@example.com' }
  let(:name)     { 'user' }
  let(:password) { 'password' }

  it 'creates a new user' do
    expect do
      post api_v1_sign_up_path, params: { user: { email:, name:, password: } }
    end.to change { User.count }.from(0).to(1)

    got = json['user']
    expect(json['jwt']).not_to be_blank
    expect(got['email']).to eq email
    expect(got['name']).to eq name

    user = User.find_by(email:)
    expect(got['id']).to eq user.id
  end
end

describe 'current user', type: :request do
  let(:email)    { 'user@example.com' }
  let(:name)     { 'user' }
  let(:password) { 'password' }

  it 'shows the current user' do
    post api_v1_sign_up_path, params: { user: { email:, name:, password: } }

    token = json['jwt']

    get api_v1_current_user_path, headers: {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{token}"
    }

    got = json
    expect(got['email']).to eq email
    expect(got['name']).to eq name

    user = User.find_by(email:)
    expect(got['id']).to eq user.id
  end
end
