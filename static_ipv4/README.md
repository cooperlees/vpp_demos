# Cooper's Lame IPv4 VPP Demo

Lets set up a Static Routed IPv4
- Relies on DHCP for the external facing VPP interface

In this demo we just setup some IPv4 links and enable NAT to go out to the Internet

## Setup
We assume you've setup vpp to have an external interface via `dpdk` mapped to `vpp`
- refer to global README.md for tips there

Setup: `./setup_demo.sh`

## Example usage
- Remember Ubuntu sets DNS to 127.0.0.53 (not going to work in netns)
```
ip netns exec vpp1 mtr 8.8.8.8
ip netns exec vpp2 mtr 8.8.8.8
```
