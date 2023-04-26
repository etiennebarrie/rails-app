module Encrypted
  extend self

  def message
    message_encryptor.encrypt_and_sign("message", purpose: :demo)
  end

  def verify(encrypted_message)
    message_encryptor.decrypt_and_verify(encrypted_message, purpose: :demo)
  rescue
  end

  def base64_decoded_hex(encrypted_message)
    Base64.decode64(encrypted_message).unpack("H*").sole
  end

  if Rails.gem_version > Gem::Version.new("7.1.a")
    def decrypted_data(encrypted_message)
      message_encryptor.send(:decrypt, encrypted_message).unpack("H*").sole
    end
  else
    def decrypted_data(encrypted_message)
      message_encryptor.send(:_decrypt, encrypted_message, :demo)
    end
  end

  private

  def message_encryptor
    @message_encryptor ||= ActiveSupport::MessageEncryptor.new("0"*32)
  end
end
