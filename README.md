# Tsumanne

[![Rake]](https://github.com/eggplants/tsumanne/actions/workflows/rake.yml)
[![Release Gem]](https://github.com/eggplants/tsumanne/actions/workflows/release.yml)
[![Gem Version]](https://badge.fury.io/rb/tsumanne)

[Rake]: <https://github.com/eggplants/tsumanne/actions/workflows/rake.yml/badge.svg>
[Release Gem]: <https://github.com/eggplants/tsumanne/actions/workflows/release.yml/badge.svg>
[Gem Version]: <https://badge.fury.io/rb/tsumanne.svg>

API Wrapper for tsumanne.net

## Installation

```bash
gem install tsumanne
```

## Usage

See: [`spec/tsumanne_spec.rb`](spec/tsumanne_spec.rb)

## CLI

```bash
tsumanne [global options] <command> [options] [arguments]
```

The board to talk to is a global option, so it comes before the command:
`-b`/`--board` takes one of `img` (default), `may`, `jun`, `dat`, `special`.

| Command | Description |
| --- | --- |
| `threads` | List the archived threads of a board (`--index`, `--page`) |
| `thread` | Print an archived thread, by id or by `YYYY/MM/DD/<thread id>` archive path |
| `search` | Find the archived thread of a 2chan.net thread URI |
| `indexes` | List the indexes, or search them by keyword (`--keyword`, `--order`, `--page`) |
| `register` | Ask the site to archive a 2chan.net thread (`--index`, repeatable) |

```bash
# list the second page of the `may` board
tsumanne --board may threads --page 2

# save an archived thread
tsumanne thread 1234567890 > thread.mht

# look up which archive a thread ended up in
tsumanne search https://may.2chan.net/b/res/1234567890.htm

# search the indexes, ordered by name instead of by newest
tsumanne indexes --keyword ねこ --order hira

# request to archive a thread
tsumanne register https://may.2chan.net/b/res/1234567890.htm
```

## Development

```bash
# install dependencies
bundle

# check code with linter / formatter && run tests
rake
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/eggplants/tsumanne>.

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/eggplants/tsumanne/blob/master/LICENSE.txt).
