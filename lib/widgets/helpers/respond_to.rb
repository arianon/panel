module RespondTo
  extend self

  def [](string, buttons)
    buttons = buttons.to_h

    io = ''
    io << buttons.map { |button, command| "%{A#{button}:#{command}:}" }.join
    io << string
    io << '%{A}' * buttons.size
  end
end
