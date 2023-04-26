class EncryptedController < ApplicationController
  def index
    @encrypted_message = Encrypted.message
  end

  def create
    message = Encrypted.verify(params[:encrypted_message])
    if message
      flash.notice = "Message verified: #{message}"
    else
      flash.alert = "Could not verify message"
    end
    redirect_to root_path
  end
end
