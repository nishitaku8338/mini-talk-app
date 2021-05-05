class MessagesController < ApplicationController
  def new
    @messages = Mesaage.all
    @message = Message.new
  end

  def create
    @message = Message.new(text: params[:message], [:text])
    binding.pry
  end
end
