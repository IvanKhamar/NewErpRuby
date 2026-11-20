require "rails_helper"

RSpec.describe Competitors::PageFetcher do
  subject(:fetcher) { described_class.new(resolver: ->(_host) { ["93.184.216.34"] }) }

  it "loads a page of the competitor's site" do
    stub_request(:get, "https://shop.example/dress").to_return(body: "<b>ok</b>",
                                                               headers: { "Content-Type" => "text/html" })

    expect(fetcher.fetch("https://shop.example/dress", "shop.example")).to eq("<b>ok</b>")
  end

  it "follows a redirect within the site, but not to another host" do
    stub_request(:get, "https://shop.example/old").to_return(status: 301, headers: { "Location" => "/new" })
    stub_request(:get, "https://shop.example/new").to_return(body: "moved")
    stub_request(:get, "https://shop.example/away").to_return(status: 302,
                                                              headers: { "Location" => "http://169.254.169.254/" })

    expect(fetcher.fetch("https://shop.example/old", "shop.example")).to eq("moved")
    expect { fetcher.fetch("https://shop.example/away", "shop.example") }
      .to raise_error(described_class::Error, /на інший сайт/)
  end

  it "refuses a host that resolves into a local network (SSRF)" do
    local = described_class.new(resolver: ->(_host) { ["10.0.0.5"] })

    expect do
      local.fetch("https://shop.example/", "shop.example")
    end.to raise_error(described_class::Error, /локальну мережу/)
  end

  it "knows which addresses are public" do
    expect(described_class.public_address?("93.184.216.34")).to be(true)
    %w[127.0.0.1 10.1.2.3 172.16.0.1 192.168.1.1 169.254.169.254 100.64.0.1 0.0.0.0 224.0.0.1 ::1 fc00::1
       ::ffff:127.0.0.1].each do |address|
      expect(described_class.public_address?(address)).to be(false), address
    end
  end

  it "turns an HTTP error into a message for people" do
    stub_request(:get, "https://shop.example/gone").to_return(status: 404)

    expect do
      fetcher.fetch("https://shop.example/gone",
                    "shop.example")
    end.to raise_error(described_class::Error, "Сайт відповів HTTP 404.")
  end
end
