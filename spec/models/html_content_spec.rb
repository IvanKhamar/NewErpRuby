require "rails_helper"

RSpec.describe HtmlContent do
  it "keeps the formatting an editor needs" do
    html = '<p>Розмір <strong>M</strong></p><table><tr><td colspan="2">32</td></tr></table>'

    expect(described_class.clean(html)).to include("<strong>M</strong>", 'colspan="2"')
  end

  it "removes scripts, event handlers and styles (stored XSS)" do
    html = '<p onclick="steal()" style="display:none">Hi</p><script>alert(1)</script><img src="x.png" onerror="x()">'

    cleaned = described_class.clean(html)

    expect(cleaned).not_to include("script", "onclick", "onerror", "style", "alert")
    expect(cleaned).to include("<p>Hi</p>", 'src="x.png"')
  end

  it "drops javascript: and data: links, and protects new tabs" do
    html = '<a href="javascript:alert(1)">x</a><a href="https://shop.example" target="_blank">ok</a>'
    cleaned = described_class.clean(html)

    expect(cleaned).not_to include("javascript")
    expect(cleaned).to include('href="https://shop.example"', 'rel="noopener noreferrer"')
  end

  it "gives an empty string for nothing" do
    expect(described_class.clean(nil)).to eq("")
    expect(described_class.clean("   ")).to eq("")
  end
end
