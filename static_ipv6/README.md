# Cooper's Site Local IPv6 VPP Demo

Lets set up a Static Routed IPv6
- Relies on autoconf + RAs

In this demo we just setup some IPv6 links. Due to using Site Local addressing we can't route to the Internet
- If you route a prefix to VPP then you could make routing to the Internet Work

## Setup
We assume you've setup vpp to have an external interface via `dpdk` mapped to `vpp`
- refer to global README.md for tips there

Setup: `./setup_demo.sh`

## Example usage
- Remember Ubuntu sets DNS to 127.0.0.53 (not going to work in netns)
```
ip netns exec vpp1 mtr fc00:0:0:200::69
ip netns exec vpp2 mtr fc00:0:0:100::69
```
- From `vppctl`: ping ipv6 2001:4860:4860::8888 source GigabitEthernet3/0/0 verbose

## Handy IPv6 Commands
- show ip6 interface GigabitEthernet3/0/0
  - All scope addresses + RA stats here
- show ip6 neighbors
- show ip6-reassembly
