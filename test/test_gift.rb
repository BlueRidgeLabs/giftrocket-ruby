require 'minitest/autorun'
require 'webmock/minitest'
require 'giftrocket'

class GiftTest < Minitest::Test
  def test_initialization
    data = {
      "amount": 30,
      "events": {
        "created_at": "2016-11-05T01:00:49.387Z",
        "delivered_at": "2016-11-05T01:02:50.057Z"
      },
      "id": "KF2BL4KDR87M",
      "message": "Thank you for your incredible work this year!",
      "order_id": "QABSTARTSFSIO",
      "recipient": {
        "email": "denise@sales.com",
        "name": "Denise Miller"
      },
      "style_id": "S0Y9RLCM26K2",
      "status": "DELIVERED"
    }.with_indifferent_access

    gift = Giftrocket::Gift.new(data)

    assert_equal data[:id], gift.id
    assert_equal data[:order_id], gift.order_id
    assert_equal data[:amount], gift.amount
    assert_equal data[:message], gift.message
    assert_equal data[:style_id], gift.style_id
    assert_equal data[:status], gift.status
    assert_equal data[:recipient][:email], gift.recipient.email
    assert_equal data[:recipient][:name], gift.recipient.name
    assert_equal data[:events], gift.events
  end

  describe 'requires config' do
    before do
      ::Giftrocket.configure do |config|
        config[:access_token] = 'abcd'
      end
    end

    def test_list
      response = {
        "gifts": [
          {
            "amount": 30,
            "events": {
              "created_at": "2016-11-05T01:00:49.387Z",
              "delivered_at": "2016-11-05T01:02:50.057Z"
            },
            "id": "KF2BL4KDR87M",
            "message": "Thank you for your incredible work this year!",
            "order_id": "QABSTARTSFSIO",
            "recipient": {
              "email": "denise@sales.com",
              "name": "Denise Miller"
            },
            "style_id": "S0Y9RLCM26K2",
            "status": "DELIVERED"
          }
        ]
      }

      stub_request(:get, 'https://www.giftrocket.com/api/v1/gifts/').
        with(query: Giftrocket.default_options).
        to_return(
          status: 200,
          body: response.to_json,
          headers: {"Content-Type"=> "application/json"}
        )
      gifts = Giftrocket::Gift.list
      assert_equal gifts.count, 1
    end

    def test_retrieve
      id = "KF2BL4KDR87M"
      response = {
        "gift": {
          "id": "KF2BL4KDR87M",
          "order_id": "DFKP4HKDRCHS",
          "amount": 25,
          "message": "Thank you for your incredible work this year!",
          "style_id": "S0Y9RLCM26K2",
          "status": "DELIVERED",
          "recipient": {
            "name": "Rachel Martel",
            "email": "rachel@sales.com"
          },
          "events": {
            "created_at": "2016-11-05T01:02:49.387Z",
            "delivered_at": "2016-11-05T01:02:50.057Z"
          }
        }
      }

      stub_request(:get, "https://www.giftrocket.com/api/v1/gifts/#{id}").
        with(query: Giftrocket.default_options).
        to_return(
          status: 200,
          body: response.to_json,
          headers: {"Content-Type"=> "application/json"}
        )
      gift = Giftrocket::Gift.retrieve(id)
      assert_equal gift.id, id
    end
  end
end
