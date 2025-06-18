#!/bin/bash

# Script to find local IP address for Flutter mobile app testing
# This script works on macOS and Linux

echo "🔍 Finding your local IP address for mobile app testing..."
echo "=================================================="

# Function to get IP address on macOS
get_macos_ip() {
    echo "🍎 Detected macOS"
    
    # Try WiFi interface first (en0)
    wifi_ip=$(ipconfig getifaddr en0 2>/dev/null)
    if [ ! -z "$wifi_ip" ]; then
        echo "📶 WiFi IP (en0): $wifi_ip"
        return 0
    fi
    
    # Try Ethernet interface (en1)
    ethernet_ip=$(ipconfig getifaddr en1 2>/dev/null)
    if [ ! -z "$ethernet_ip" ]; then
        echo "🔌 Ethernet IP (en1): $ethernet_ip"
        return 0
    fi
    
    # Fallback to ifconfig parsing
    echo "🔍 Searching all interfaces..."
    ifconfig | grep "inet " | grep -v 127.0.0.1 | while read line; do
        ip=$(echo $line | awk '{print $2}')
        interface=$(echo $line | awk '{print $1}' | cut -d: -f1)
        echo "   Interface: $interface, IP: $ip"
    done
}

# Function to get IP address on Linux
get_linux_ip() {
    echo "🐧 Detected Linux"
    
    # Try hostname command first
    if command -v hostname >/dev/null 2>&1; then
        hostname_ip=$(hostname -I | awk '{print $1}')
        if [ ! -z "$hostname_ip" ]; then
            echo "🌐 Primary IP: $hostname_ip"
        fi
    fi
    
    # Show all non-loopback IPs
    echo "🔍 All network interfaces:"
    ip addr show | grep "inet " | grep -v 127.0.0.1 | while read line; do
        ip=$(echo $line | awk '{print $2}' | cut -d/ -f1)
        interface=$(ip addr show | grep -B2 "$line" | head -1 | awk '{print $2}' | cut -d: -f1)
        echo "   Interface: $interface, IP: $ip"
    done
}

# Detect OS and get IP
if [[ "$OSTYPE" == "darwin"* ]]; then
    get_macos_ip
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    get_linux_ip
else
    echo "❓ Unknown OS. Trying generic approach..."
    ifconfig 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | while read line; do
        ip=$(echo $line | awk '{print $2}')
        echo "   IP: $ip"
    done
fi

echo ""
echo "📱 Instructions for Flutter app:"
echo "1. Choose the IP address that matches your WiFi network"
echo "2. Usually starts with 192.168.x.x or 10.x.x.x"
echo "3. Update the Flutter app configuration with this IP"
echo "4. Make sure your mobile device is on the same WiFi network"
echo ""
echo "🔧 Next steps:"
echo "1. Copy the IP address (usually the WiFi one)"
echo "2. Update lib/config/app_config.dart with this IP"
echo "3. Restart your backend server to accept connections from all interfaces"
