require 'spec_helper'

describe 'global configuration stuff' do

  before :all do
    module TheApi
      class ConfigurationApi < Grape::API
        format :json
        version 'v3', using: :path

        desc 'This returns something',
          failure: [{code: 400, message: 'NotFound'}]
        params do
          requires :foo, type: Integer
        end
        get :configuration do
          { "declared_params" => declared(params) }
        end

        add_swagger_documentation format: :json,
                                  api_version: '23',
                                  schemes: 'https',
                                  host: -> { 'another.host.com' },
                                  base_path: -> { 'somewhere/over/the/rainbow' },
                                  mount_path: 'documentation',
                                  add_base_path: true,
                                  add_version: true

      end
    end
  end

  def app
    TheApi::ConfigurationApi
  end

  describe "shows documentation paths" do
    subject do
      get '/v3/documentation'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['host']).to eql 'another.host.com'
      expect(subject['basePath']).to eql 'somewhere/over/the/rainbow'
      expect(subject['paths'].keys.first).to eql '/somewhere/over/the/rainbow/v3/configuration'
      expect(subject['schemes']).to eql ['https']
    end
  end

end
