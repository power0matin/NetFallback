# Protocol and tool notes

NetFallback archives official releases; it does not automatically configure, install, or test a tunnel. Keep the distinction between **filtering evasion** (a route may still exist but be identified/blocked) and **a network shutdown** (the required route may not exist at all).

| Family | What it tries to do | Important dependency / failure mode |
| --- | --- | --- |
| WARP / MASQUE | Carry traffic through Cloudflare's WARP service using a MASQUE transport such as HTTP/2 or HTTP/3, depending on client support | Requires a usable WARP identity/key and endpoint/service connectivity. Blocking the relevant Cloudflare path can stop it. A generic WARP install is not identical to every Aether/PattNG MASQUE workflow. |
| SNI spoofing / fragmentation | Alter how TLS ClientHello/SNI or packet boundaries appear to middleboxes | Effectiveness varies by DPI implementation, network path, IP address, TLS behavior, and destination. It is not a new physical route. |
| MHRV | Relay traffic using its project-specific client and relay components | Often requires initial setup; full-tunnel configurations can require a relay/deployment and possibly an exit node. Check the upstream version's current docs, quotas, and trust model. |
| Xray-based direct/fragment configurations | Use protocol/configuration combinations that may avoid some filtering rules | Configurations and reachable endpoints can expire. A config that downloads successfully may still fail on a particular ISP or destination. |
| Cloudflare-hosted Workers/Pages or custom domains | Use an accessible hosted endpoint as a relay/proxy where the project and provider terms allow it | Depends on domain/IP/IPv6 accessibility, deployment state, provider limits, and destination restrictions. Workers and Pages are not interchangeable. |
| IPv6-specific paths | Use an IPv6 route if the ISP and destination actually provide working IPv6 | IPv6 support must exist end-to-end; enabling IPv6 on a device alone does not create an independent international route. |

## Operational checklist

1. Test each method on the actual mobile/fixed ISP you rely on, while normal internet is available.
2. Keep more than one *mechanistically different* method, not only multiple clients using the same upstream service.
3. Store installation packages and their release metadata separately from live configs.
4. Keep setup material for any relay, key, or deployment you control. Store secrets in encrypted local storage; do not commit them.
5. Record when a method was last tested, including ISP, access type, date, DNS/IP family, and result. Do not post sensitive personal identifiers or private endpoints in public issues.
6. If all paths to the foreign internet are blocked, client-side proxy software cannot create a new route by itself.

## Safety note

This document is a taxonomy, not a claim of present-day availability. NetFallback does not conduct live ISP measurements. Do not assume an entry works because its release exists or a config is downloadable.
