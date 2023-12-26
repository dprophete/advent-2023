## Advent of code - 2023

My first time doing it.

# python
I started in python, with a `p1.py` and `p2.py` in each dir. Just execute them.

# elixir
On day 9, I decided to leanr elixir so I redid all of the initial python ones in elixir. 
Instead of 2 files per day, I have a simple `.ex` files with 2 modules (`P1` and `P2`). Just edit the file to run one or the other

After day 10, I just did elixir.

# mix
On day 14, I started using the mix elixir toolchain, so the structure is a little different (this was so I could leverage dializer and a public sorted heap library).

Turns out that mix is great for leverage the full elixir ecosystem, but not as good to just run a script (withouth the whole erlang OTP machinery).

I asked the community and eventyally using `mix test` does the trick: https://elixirforum.com/t/mix-project-for-a-simple-script/60507
