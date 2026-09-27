#!/bin/bash
# 🔒 Surokkha System V2 - Master Protected
BASE="/storage/emulated/0/Surakkha-System"
CDIR="$BASE/.surakkha/confirmed"
HFILE="$BASE/.surakkha/history.json"
LFILE="$BASE/.surakkha.lock"
mkdir -p "$CDIR" "$BASE/.surakkha" "$BASE/master" "$BASE/projects"

cmd="$1"; file="$2"

do_lock(){ chmod 444 "$BASE/$1" 2>/dev/null || chmod 444 "$1"; echo "$1::LOCKED:$(date +%Y%m%d_%H%M%S)" >> "$LFILE"; echo "🔒 LOCKED: $1"; }
do_unlock(){ chmod 644 "$BASE/$1" 2>/dev/null || chmod 644 "$1"; echo "🔓 UNLOCKED: $1"; }

case "$cmd" in
  lock) [ -z "$file" ] && echo "Usage: bash safe.sh lock <file>" && exit 1; do_lock "$file" ;;
  unlock) [ -z "$file" ] && echo "Usage: bash safe.sh unlock <file>" && exit 1; do_unlock "$file" ;;
  status) echo "=== Surokkha V2 Status ==="; ls -l "$BASE"/index.html "$BASE"/safe.sh 2>/dev/null; echo "--- LOCK Log ---"; tail -20 "$LFILE"; echo "--- Confirmed ---"; ls -1 "$CDIR" 2>/dev/null ;;
  stage|snapshot) [ -z "$file" ] && file="part-$(date +%H%M)"; cp "$BASE/index.html" "$CDIR/${file}_$(date +%Y%m%d_%H%M%S).html"; echo "📸 Snapshot: $file"; ;;
  confirm) [ -z "$file" ] && echo "Usage: bash safe.sh confirm part-01-name" && exit 1; cp "$BASE/index.html" "$CDIR/${file}_CONFIRMED_$(date +%Y%m%d_%H%M%S).html"; chmod 444 "$CDIR/${file}_CONFIRMED_"*.html; echo "{\"part\":\"$file\",\"time\":\"$(date)\",\"status\":\"CONFIRMED\"}" >> "$HFILE"; echo "✅ CONFIRMED & LOCKED: $file - এখন নষ্ট হবে না"; ;;
  history) echo "=== Part History ==="; cat "$HFILE" 2>/dev/null; echo ""; ls -lt "$CDIR" | head -20 ;;
  back) LAST=$(ls -t "$CDIR"/*CONFIRMED* 2>/dev/null | sed -n '2p'); [ -n "$LAST" ] && cp "$LAST" "$BASE/index.html" && echo "⏪ Back to: $LAST" || echo "No previous"; ;;
  next) FIRST=$(ls -t "$CDIR"/*CONFIRMED* 2>/dev/null | head -n1); [ -n "$FIRST" ] && cp "$FIRST" "$BASE/index.html" && echo "⏩ Next to: $FIRST" || echo "No next"; ;;
  transfer) echo "Master -> Project: bash safe.sh transfer $2 $3 --only-confirmed"; [ "$4" = "--only-confirmed" ] && cp -r "$BASE/master/$2" "$BASE/projects/$3" 2>/dev/null; cp "$BASE/index.html" "$BASE/projects/$3.html"; chmod 444 "$BASE/projects/$3.html"; echo "✅ Transfer LOCKED: projects/$3.html" ;;
  lock-self) chmod 444 "$BASE/safe.sh"; chmod 444 "$LFILE" 2>/dev/null; echo "🔒🔒🔒 Surokkha নিজেই LOCKED - AI এখন শুধু তুমি যতটুকু বলবে ততটুকুই পরিবর্তন করবে"; ;;
  *) echo "Surokkha V2 Commands:"; echo "  status | history | back | next"; echo "  snapshot part-01 | confirm part-01"; echo "  lock <file> | unlock <file> | lock-self"; echo "  transfer master proj --only-confirmed"; ;;
esac
