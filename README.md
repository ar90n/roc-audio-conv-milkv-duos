# roc-audio-conv-milkv-duos

A project to expose audio devices over the network using roc-toolkit on Milk-V Duo S.

## Overview

This project integrates [roc-toolkit](https://roc-streaming.org/) with the [Milk-V Duo S](https://milkv.io/duo-s) board to expose audio devices over the network. Roc-toolkit is a toolkit for real-time audio streaming over the network with high quality.

## Features

- Build custom Linux image for Milk-V Duo S
- High-quality network audio streaming with roc-toolkit integration
- Automatic Wi-Fi connection setup
- Audio input/output support via ALSA devices

## Requirements

- Docker & Docker Compose
- Milk-V Duo S board
- microSD card (Recommended: 8GB or larger)
- USB Wi-Fi dongle with RTL8192EU chipset (or compatible)
  - **Note**: This project is designed for Wi-Fi usage and requires a USB Wi-Fi dongle
  - Tested with RTL8192EU-based dongles

## Setup

### 1. Configure Environment Variables

Copy `.env.template` to create a `.env` file and fill in the required information:

```bash
cp .env.template .env
```

Edit the `.env` file with the following information:

```bash
# IP address of the host running roc-receiver
ROC_RECEIVER_IP=192.168.1.100

# Wi-Fi connection information
WPA_SUPPLICANT_SSID=your_wifi_ssid
WPA_SUPPLICANT_PSK=your_wifi_password
```

#### Configuration Parameters

- **ROC_RECEIVER_IP**: IP address of the host that will receive the audio stream
- **WPA_SUPPLICANT_SSID**: SSID of the Wi-Fi network to connect to
- **WPA_SUPPLICANT_PSK**: Password for the Wi-Fi network

### 2. Build the Image

```bash
# First time only: Initialize and download SDK
docker compose run --rm init
# Build the image
docker compose run --rm build
```

After the build completes, an SD card image will be generated in the `output/` directory.

### 3. Write to SD Card

Write the generated image to a microSD card:

```bash
# Linux/macOS
sudo dd if=output/milkv-duos-*.img of=/dev/sdX bs=4M status=progress
sudo sync
```

**Note**: Replace `/dev/sdX` with your actual SD card device name.

### 4. Boot Milk-V Duo S

1. Insert the written microSD card into Milk-V Duo S
2. Connect USB Wi-Fi dongle (RTL8192EU-based recommended)
3. Connect power to boot the board

Once the board boots up, it will automatically connect to Wi-Fi and start streaming audio to the configured roc-receiver host.

## Usage

### Sender on Milk-V Duo S

The board automatically starts streaming audio using roc-send. The default configuration sends audio from the onboard microphone to the configured receiver.

If you need to manually control roc-send:

```bash
# Example: Send audio from ALSA device to receiver
roc-send -vv -s rtp+rs8m://<RECEIVER_IP>:10001 -r rs8m://<RECEIVER_IP>:10002 -i alsa -d hw:0,0
```

### Receiver Setup (PC/Server)

To receive the audio stream from Milk-V Duo S, run roc-receiver on the receiving side:

```bash
# Install roc-toolkit (Ubuntu/Debian)
sudo apt install roc-toolkit

# Receive audio stream
roc-recv -vv -s rtp+rs8m://0.0.0.0:11001 -r rs8m://0.0.0.0:11002 -d alsa -o default
```

#### macOS Users

On macOS, you can use [roc-vad](https://github.com/roc-streaming/roc-vad) for seamless integration:

```bash
# Install roc-toolkit via Homebrew
brew install roc-toolkit

# Use roc-vad to create a virtual audio device
# The virtual device will appear in System Settings > Sound
roc-recv -vv -s rtp+rs8m://0.0.0.0:11001 -r rs8m://0.0.0.0:11002 -d vad
```

The virtual audio device created by `roc-vad` will be available system-wide and can be selected as an input source in any audio application.

### Changing Transmission Ports

By default, the following ports are used:

- **Sender**: 10001 (stream), 10002 (repair)
- **Receiver**: 11001 (stream), 11002 (repair)

To change these ports, edit the `external/template/roc-aoip` file.

## Customization

### Modify Buildroot Configuration

```bash
# Open build configuration menu
make menuconfig

# Save configuration
make savedefconfig
```

### Adding Packages

You can add new packages to the `external/package/` directory. Refer to existing packages (`roc-toolkit/`, `rtl8xxxu/`) for examples.

## Troubleshooting

### Cannot Connect to Wi-Fi

- Verify that the SSID and password in the `.env` file are correct
- Ensure your Wi-Fi router supports 2.4GHz band (Milk-V Duo S may not support 5GHz)

### Cannot Receive Audio Stream

- Verify that `ROC_RECEIVER_IP` is correct
- Check that the necessary ports (10001, 10002, 11001, 11002) are open in your firewall settings
- Ensure roc-receiver is running correctly on the receiving side

### SSH Access to Device

```bash
ssh root@<Milk-V-Duo-S-IP-Address>
# Default password: milkv
```

## License

See the [LICENSE](LICENSE) file for information about this project's license.

## References

- [Milk-V Duo S](https://milkv.io/duo-s)
- [roc-toolkit](https://roc-streaming.org/)
- [duo-buildroot-sdk-v2](https://github.com/milkv-duo/duo-buildroot-sdk-v2)
