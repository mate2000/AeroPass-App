# TLS trust anchors (015 research.md §4)

These are the only roots the app trusts, through `buildPinnedDio` and the Clerk `HttpService`. A
chain that does not end in one of them fails the handshake, which fails closed.

The deployed chains were checked with `openssl s_client` on 2026-09-23:

| Host | Chain |
|---|---|
| `aeropass-lac.vercel.app` | `*.vercel.app` → GTS WR1 → GTS Root R1 |
| `api.clerk.com` | → GTS WE1 → GTS Root R4 |

| File | Source | SHA-256 fingerprint | Expires |
|---|---|---|---|
| gts-root-r1.pem | https://pki.goog/repo/certs/gtsr1.pem | D9:47:43:2A:BD:E7:B7:FA:90:FC:2E:6B:59:10:1B:12:80:E0:E1:C7:E4:E4:0F:A3:C6:88:7F:FF:57:A7:F4:CF | 2036-06-22 |
| gts-root-r2.pem | https://pki.goog/repo/certs/gtsr2.pem | 8D:25:CD:97:22:9D:BF:70:35:6B:DA:4E:B3:CC:73:40:31:E2:4C:F0:0F:AF:CF:D3:2D:C7:6E:B5:84:1C:7E:A8 | 2036-06-22 |
| gts-root-r3.pem | https://pki.goog/repo/certs/gtsr3.pem | 34:D8:A7:3E:E2:08:D9:BC:DB:0D:95:65:20:93:4B:4E:40:E6:94:82:59:6E:8B:6F:73:C8:42:6B:01:0A:6F:48 | 2036-06-22 |
| gts-root-r4.pem | https://pki.goog/repo/certs/gtsr4.pem | 34:9D:FA:40:58:C5:E2:63:12:3B:39:8A:E7:95:57:3C:4E:13:13:C8:3F:E6:8F:93:55:6C:D5:E8:03:1B:3C:7D | 2036-06-22 |

All four GTS roots are kept, so a change between RSA and ECDSA issuance on Vercel or Clerk does not
break the app. Before any build that uses a Clerk instance, re-check the Frontend API host of that
instance (quickstart prerequisite).
