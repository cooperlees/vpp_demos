# Ubuntu 18.04 Setup VPP

This was for VPP 19.04 release

- Add to apt
```
sudo apt-get update
sudo apt-get install debian-archive-keyring curl gnupg apt-transport-https

curl -L https://packagecloud.io/fdio/1904/gpgkey | sudo apt-key add -
echo -e "deb https://packagecloud.io/fdio/1904/ubuntu/ bionic main\ndeb-src https://packagecloud.io/fdio/1904/ubuntu/ bionic main" \
  > /etc/apt/sources.list.d/fdio_1904.list

sudo apt-get update

sudo apt-get install python3-vpp-api vpp vpp-plugin-core vpp-plugin-dpdk
```
