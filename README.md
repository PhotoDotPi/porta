# Porta

Porta is a lightweight, concurrent TCP port scanner written in Elixir.

It discovers accessible TCP ports on a single IPv4 host or a small IPv4 CIDR range and maps well-known ports to conventional service names.

## Documentation

Full API documentation is available at **https://photodotpi.github.io/porta/**.

## Features

- Single IPv4 addresses and IPv4 CIDR ranges
- Port lists, comma-separated values, and ranges (`22,80,443`, `1-1024`)
- Bounded concurrency with configurable limits
- Configurable TCP connection timeouts
- Local service-name lookup for common ports
- Clean, aligned terminal table output
- No external dependencies

## Requirements

- Elixir 1.20+
- Erlang/OTP 27+

## Build

```bash
mix deps.get
mix escript.build
```

This produces an executable named `porta`.

## Usage

```bash
porta 192.168.1.10
porta 192.168.1.10 --ports 22,80,443
porta 192.168.1.0/24 --ports 80,443 --timeout 1000
porta 192.168.1.10 --ports 1-1024 --concurrency 100
porta --help
porta --version
```

## Options

| Option | Alias | Description |
|---|---|---|
| `--ports` | `-p` | Comma-separated TCP ports and/or ranges |
| `--timeout` | `-t` | TCP connection timeout in milliseconds (default: 1000) |
| `--concurrency` | `-c` | Maximum concurrent connection tasks (default: 50, max: 1000) |
| `--help` | `-h` | Display usage information |
| `--version` | `-v` | Display application version |

Default ports (when `--ports` is omitted): 21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1433, 1521, 3306, 3389, 5432, 5900, 6379, 8080, 8443.

## Example Output

```text
                                        ▄▄▄▀▀▀█
                                         █   █
  ▀▄▄▄▄▄▄▄▀     ▀▄▄▄▄▄▄▄▀     ▀▄▄▄▄▄▄▄▀  █ ░ █▄▄▄    ▄▀▀▒▀▀▄█▄▄▄▄▄
 ██▓██▀██▓██   ██▓██▀██▓██   ██▓██▀██▓█  █░▒░▀▓█▀▀  █ ░ █   ░█▓██
█▓▒▓     ▓▒▓█ █▓▒▓     ▓▒▓█ █▓▒▓ ▌ ▐ ▓▒  █▒▓▒██░█  █░▒░█    █▓▒▓█
█▒░▒▓   ▓▒░▒█ █▒░▒▓   ▓▒░▒█ █▒░▒▓        █▓█▓░▒▀   █▒▓▒█    █▒░▒░
█░ ░▓   ▓░ ░█ █░ ░▓   ▓░ ░█ █░ ░▓        █ ░ ▒░    █▓█▓█    █░ ░▒
██ ░▒ ▄ ▒░ █   █ ░▒ ▄ ▒░ █  ██ ░░        █░▒░▓▓▄■▄  █░▒░ ▄ ▄█ ░ ▓
█░█░■▄■▄▄▄▀     ▀▄▄▄■▄▄▄▀   ▄▄▀▄▄        ■▀▀▀▄▀▀▀▀    ▀▀▀▀▀  ▀■▄█▄
█▒█▒█                                   ▀▀
█▓▄▓█
▀▀▀▀▀

  Porta v0.1.0
  Local Network Scanner


Target: 192.168.1.10
Ports:  22, 80, 443, 8080
Status: Scan completed

┌───────────────┬──────┬─────────────┐
│ IP Address    │ Port │ Service     │
├───────────────┼──────┼─────────────┤
│ 192.168.1.10  │ 22   │ SSH         │
│ 192.168.1.10  │ 80   │ HTTP        │
│ 192.168.1.10  │ 443  │ HTTPS       │
└───────────────┴──────┴─────────────┘

3 open ports found.
Scan completed successfully.
```

## Testing

```bash
mix test
mix format --check-formatted
mix compile --warnings-as-errors
```

## Architecture

- `Porta.CLI` — entry point and orchestration
- `Porta.Arguments` — option parsing and validation
- `Porta.Target` — IPv4 and CIDR parsing/expansion
- `Porta.Ports` — port specification parsing
- `Porta.Scanner` — bounded-concurrency TCP connect scanning
- `Porta.ServiceMap` — conventional port-to-service mapping
- `Porta.Formatter` — terminal output rendering

## Authorized Use

Only scan networks and hosts you own or have explicit authorization to assess. Porta performs ordinary TCP connect scans only and does not implement stealth scanning, packet crafting, or exploitation.
