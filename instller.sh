#!/bin/bash
# ==========================================================
# 🔴 ReStream Script (Interactive)
# Streams a remote video URL directly to any RTMP server (YouTube, Twitch, etc.)
# without saving the video locally.
# ==========================================================

echo "==========================================="
echo "     🔴 LINK ➜ RTMP Auto Stream Script"
echo "     Created by leveluplegends"
echo "==========================================="

# --- Step 1: Install FFmpeg if not installed ---
if ! command -v ffmpeg &> /dev/null; then
    echo "📦 FFmpeg not found. Installing..."
    sudo apt update -y
    sudo apt install -y ffmpeg
else
    echo "✅ FFmpeg already installed."
fi

# --- Step 2: Ask user for inputs ---
echo ""
read -p "🎬 Enter video URL (e.g. https://example.com/video.mp4 or .m3u8): " VIDEO_URL
read -p "📡 Enter RTMP URL (e.g. rtmp://a.rtmp.youtube.com/live2/YOUR_KEY): " RTMP_URL

# --- Step 3: Validate input ---
if [[ -z "$VIDEO_URL" || -z "$RTMP_URL" ]]; then
    echo "⚠️  Both video URL and RTMP URL are required!"
    exit 1
fi

# --- Step 4: Confirm ---
echo ""
echo "==========================================="
echo "🎥 Video Source : $VIDEO_URL"
echo "🚀 RTMP Target  : $RTMP_URL"
echo "==========================================="
sleep 2

# --- Step 5: Start FFmpeg streaming ---
echo "🔥 Starting live stream... (Press Ctrl + C to stop)"
ffmpeg -re -i "$VIDEO_URL" \
-c:v libx264 -preset veryfast -maxrate 3000k -bufsize 6000k -pix_fmt yuv420p \
-c:a aac -b:a 128k -ar 44100 -ac 2 \
-f flv "$RTMP_URL"

echo ""
echo "✅ Stream ended or interrupted."
