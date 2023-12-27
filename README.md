# StockEx

Just a simple project(kind of Investment Platform), to address the proposed code assignment from Treasury.

## Setup

### Running the app:

*
```sh
git clone https://github.com/3fernandez/stock_ex
cd stock_ex
```

* If you are using `asdf` for package management, just run:
```sh
asdf install
```

* Make sure copy `.env.example`, rename it to `.env`, set your own desired values and source it.

* Run `mix setup` to install and setup dependencies.

* Run `mix test` for the tests.

* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`, and visit [`localhost:4000`](http://localhost:4000) from your browser.

* After you create an account(register a user), go to: [`mailbox`](http://localhost:4000/dev/mailbox) in another tab, to confirm your registered account.
