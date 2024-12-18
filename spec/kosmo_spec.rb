# frozen_string_literal: true

RSpec.describe Kosmo::Client do
  let(:api_key) { ENV["KOSMO_API_KEY"] }
  let(:client) { Kosmo::Client.new(api_key) }

  let(:order_params) do
    {
      customer: {
        name: "John Tan",
        phone: "+6591234567",
        email: "john.tan@example.com"
      },
      pickup: {
        location: {
          address: "313 Orchard Road, Singapore 238895",
          latitude: 1.3021,
          longitude: 103.8368,
          country: "SG"
        },
        sender: {
          fullname: "John Tan",
          phone: "+6591234567",
          email: "john.tan@example.com"
        }
      },
      dropoffs: [
        {
          location: {
            address: "18 Marina Gardens Drive, Singapore 018953",
            latitude: 1.2819,
            longitude: 103.8636,
            country: "SG"
          },
          receiver: {
            fullname: "John Tan",
            phone: "+6591234567",
            email: "john.tan@example.com"
          }
        }
      ],
      items: [
        {
          name: "Singapore Sling",
          quantity: 2,
          price: 15.00
        }
      ],
      delivery_type: "ASAP"
    }
  end

  let(:quote_params) { order_params.except(:customer) }

  before do
    raise "KOSMO_API_KEY environment variable not set" unless api_key
  end

  describe "#initialize" do
    it "creates a new client with the given API key" do
      expect(client.instance_variable_get(:@api_key)).to eq(api_key)
    end

    it "sets up a Faraday connection" do
      expect(client.instance_variable_get(:@connection)).to be_a(Faraday::Connection)
    end
  end

  describe "#create_quotes" do
    it "creates quotes successfully" do
      response = client.create_quotes(quote_params)
      expect(response).to be_a(Hash)
      expect(response["quotes"]).to be_an(Array)
      expect(response["quotes"].first).to include("provider", "price")
    end
  end

  describe "#create_order" do
    it "creates an order successfully" do
      response = client.create_order(order_params)
      expect(response).to be_a(Hash)
      expect(response["order"]["deliveryId"]).to be_a(String)
      expect(response["order"]["status"]).to eq("created")
    end
  end

  describe "#list_orders" do
    it "lists orders successfully" do
      response = client.list_orders
      expect(response).to be_a(Hash)
      expect(response["orders"]).to be_an(Array)
    end

    it "accepts query parameters" do
      params = { limit: 5, status: "completed" }
      response = client.list_orders(params)
      expect(response).to be_a(Hash)
      expect(response["orders"]).to be_an(Array)
    end
  end

  describe "#get_order" do
    let!(:created_order) { client.create_order(order_params) }
    let(:order_id) { created_order["order"]["id"] }

    it "retrieves an order successfully" do
      response = client.get_order(order_id)

      expect(response).to be_a(Hash)
      expect(response["id"]).to eq(order_id)
      expect(response["status"]).to eq("created")
    end
  end

  describe "error handling" do
    it "raises a NotFoundError for a non-existent order" do
      expect { 
        client.get_order("non_existent_id") 
      }.to raise_error(Kosmo::NotFoundError)
    end

    it "raises an UnauthorizedError with invalid API key" do
      invalid_client = Kosmo::Client.new("invalid_api_key")
      expect { 
        invalid_client.list_orders 
      }.to raise_error(Kosmo::UnauthorizedError)
    end
  end
end
