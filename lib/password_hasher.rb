# PBKDF2 password hashes in the ASP.NET Core Identity v3 format.
#
# The .NET, Java and Python versions read and write the same erp_user_login.password_hash, so the format must match:
# base64 of [0x01][prf: uint32][iterations: uint32][salt length: uint32][salt][subkey], numbers big-endian.
# That is why this is not bcrypt / has_secure_password (see DECISIONS.md D6).
class PasswordHasher
  FORMAT_V3 = 0x01
  PRF_DIGESTS = { 0 => "SHA1", 1 => "SHA256", 2 => "SHA512" }.freeze
  PRF_SHA512 = 2
  ITERATIONS = 100_000
  SALT_SIZE = 16
  SUBKEY_SIZE = 32

  # The count is stored in each hash, so test data may use a cheap one and still verify here.
  def initialize(iterations: ITERATIONS)
    @iterations = iterations
  end

  def hash(password)
    salt = SecureRandom.random_bytes(SALT_SIZE)
    subkey = pbkdf2(password, salt, @iterations, SUBKEY_SIZE, "SHA512")
    header = [FORMAT_V3, PRF_SHA512, @iterations, SALT_SIZE].pack("CN3")
    Base64.strict_encode64(header + salt + subkey)
  end

  def verify(password_hash, password)
    blob = Base64.strict_decode64(password_hash.to_s)
    return false if blob.bytesize < 13 || blob.getbyte(0) != FORMAT_V3

    prf, iterations, salt_size = blob.byteslice(1, 12).unpack("N3")
    digest = PRF_DIGESTS[prf]
    salt = blob.byteslice(13, salt_size)
    expected = blob.byteslice((13 + salt_size)..)
    return false if digest.nil? || salt_size < 16 || salt.bytesize != salt_size || expected.to_s.bytesize < 16

    actual = pbkdf2(password, salt, iterations, expected.bytesize, digest)
    ActiveSupport::SecurityUtils.secure_compare(actual, expected)
  rescue ArgumentError
    false # not base64
  end

  private

  def pbkdf2(password, salt, iterations, length, digest)
    OpenSSL::KDF.pbkdf2_hmac(password.to_s, salt:, iterations:, length:, hash: digest)
  end
end
