require "rails_helper"

RSpec.describe PasswordHasher do
  subject(:hasher) { described_class.new(iterations: 1_000) }

  it "verifies its own hash and refuses another password" do
    hash = hasher.hash("fake-password")

    expect(hasher.verify(hash, "fake-password")).to be(true)
    expect(hasher.verify(hash, "fake-passwore")).to be(false)
  end

  it "writes the ASP.NET Core Identity v3 layout: marker, PRF, iterations, salt size, salt, subkey" do
    blob = Base64.strict_decode64(hasher.hash("fake-password"))

    expect(blob.getbyte(0)).to eq(0x01)
    expect(blob.byteslice(1, 12).unpack("N3")).to eq([2, 1_000, 16]) # HMAC-SHA512, 1000 rounds, 16-byte salt
    expect(blob.bytesize).to eq(13 + 16 + 32)
  end

  it "verifies a hash made with another PRF (SHA-256), as older .NET hashes may be" do
    salt = "s" * 16
    subkey = OpenSSL::KDF.pbkdf2_hmac("fake-password", salt:, iterations: 500, length: 32, hash: "SHA256")
    hash = Base64.strict_encode64([1, 1, 500, 16].pack("CN3") + salt + subkey)

    expect(hasher.verify(hash, "fake-password")).to be(true)
  end

  it "refuses broken hashes instead of raising" do
    expect(hasher.verify("not base64 at all!", "x")).to be(false)
    expect(hasher.verify(Base64.strict_encode64("\x00short"), "x")).to be(false)
    expect(hasher.verify(nil, "x")).to be(false)
  end
end
