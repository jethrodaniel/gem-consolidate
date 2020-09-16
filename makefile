B=bundle exec
CMD=$(B) rake install && $(B) gem consolidate example/lib/fib.rb
# CMD=$(B) bin/consolidate example/lib/fib.rb
NADA=/dev/null
1:
	$(CMD) 2>$(NADA)
2:
	$(CMD) 1>$(NADA)
run: fib.bundle.rb
	ruby $<
fib.bundle.rb:
	$(CMD) --footer='1.upto(10).each{|n|p Fib.fibonacci(n)}' > $@
clean:
	rm -f fib.bundle.rb
