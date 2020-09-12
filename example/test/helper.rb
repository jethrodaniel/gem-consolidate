def sh command_string
  print "sh: "
  print system(command_string) ? " ok" : " failed"
  puts
end
