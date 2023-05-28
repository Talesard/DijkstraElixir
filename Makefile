
help:
	@echo off && echo "gen <n=>; par <n=>; ser <n=>; bench <n=>"

gen:
	elixir generator.exs ${n}

par:
	elixir parallel.exs ${n}

ser:
	elixir serial.exs ${n}

bench:
	python bench.py ${n}