cat > client.sh << 'EOF'
#!/usr/bin/env bash
SERVER_IP="${1:-tosdto.servebeer.com}"
PORT="${2:-4444}"
JOIN="__JOIN__"; BYE="__BYE__"

case "${LC_ALL}${LANG}" in
    *UTF-8*|*utf8*) ;;
    *) export LC_ALL=C.UTF-8 ;;
esac

G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; C=$'\e[36m'
B=$'\e[1m'; D=$'\e[2m'; N=$'\e[0m'
PROMPT_RL=$'\001\e[36m\002You ›\001\e[0m\002 '
PROMPT_PL=$'\e[36mYou ›\e[0m '

fix_rtl() {
    local s="$1" out="" i
    if [[ $s =~ [ء-ي] ]]; then
        for ((i=${#s}-1; i>=0; i--)); do out+="${s:i:1}"; done
        printf '%s' "$out"
    else
        printf '%s' "$s"
    fi
}

trap '' PIPE

if ! { exec 3<>"/dev/tcp/$SERVER_IP/$PORT"; } 2>/dev/null; then
    printf '%s● Connection failed%s\n' "$R" "$N"
    exit 1
fi
printf '%s\n' "$JOIN" >&3

cleanup() {
    trap - EXIT INT TERM
    printf '%s\n' "$BYE" >&3 2>/dev/null
    exec 3>&- 3<&-
    kill 0 2>/dev/null
}
trap cleanup EXIT
trap 'printf "\n${Y}● You left the chat${N}\n"; exit 0' INT TERM

clear
printf '%s╭──────────────────────────────╮%s\n' "$C" "$N"
printf '%s│%s          %sChat%s                %s│%s\n' "$C" "$N" "$B" "$N" "$C" "$N"
printf '%s╰──────────────────────────────╯%s\n' "$C" "$N"
printf '%s● Connected%s\n' "$G" "$N"
printf '%sType a message + Enter · Ctrl+C to quit%s\n\n' "$D" "$N"

{
    while IFS= read -r line; do
        line="${line%$'\r'}"
        line="$(fix_rtl "$line")"
        printf '\r\033[K%s[%s]%s %sServer%s: %s\n%s' \
            "$D" "$(date +%H:%M)" "$N" "$G" "$N" "$line" "$PROMPT_PL"
    done <&3
    printf '\r\033[K%s● Disconnected — server closed the connection%s\n' "$R" "$N"
    kill -TERM $$ 2>/dev/null
} &

while IFS= read -e -r -p "$PROMPT_RL" msg; do
    [ -z "$msg" ] && continue
    printf '%s\n' "$msg" >&3 || break
done
EOF
chmod +x client.sh
