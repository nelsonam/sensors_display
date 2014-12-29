require 'serialport'
s = SerialPort.new '/dev/ttyACM0', 38400
puts "(connected)"
loop do
#  puts s.readline.chomp
  print s.read(1)
end
