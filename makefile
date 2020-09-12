B=bundle exec
CMD=$(B) rake install && $(B) gem consolidate example/lib/fib.rb
NADA=/dev/null
1:
	$(CMD) 2>$(NADA)
2:
	$(CMD) 1>$(NADA)
