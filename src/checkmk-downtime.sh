#!/bin/bash

set -euo pipefail

# Default-Konfiguration
CHECKMK_URL=""
CHECKMK_USER=""
CHECKMK_SECRET=""
DOWNTIME_MINUTES=11
HOSTNAME_FILE="/etc/check_mk/hostname.cfg"
LOG_LEVEL="INFO"

# Konfigurationsdatei laden
CONFIG_FILE="/etc/check_mk/downtime.cfg"

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
else
    echo "ERROR: Configuration file $CONFIG_FILE not found!"
    echo "Please create the configuration file with your CheckMK settings."
    exit 1
fi

# Validierung der erforderlichen Parameter
if [[ -z "$CHECKMK_URL" || -z "$CHECKMK_USER" || -z "$CHECKMK_SECRET" ]]; then
    echo "ERROR: Missing required configuration parameters!"
    echo "Please check your configuration file: $CONFIG_FILE"
    exit 1
fi

# Logging-Funktion
log() {
    local level="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $level: $message" | systemd-cat -t checkmk-downtime

    if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $level: $message" >&2
    fi
}

# Hostname ermitteln
get_hostname() {
    local hostname=""

    if [[ -f "$HOSTNAME_FILE" ]]; then
        hostname=$(cat "$HOSTNAME_FILE" | tr -d '\n\r' | xargs)
        log "INFO" "Hostname from $HOSTNAME_FILE: $hostname"
    elif [[ -n "${HOSTNAME:-}" ]]; then
        hostname="$HOSTNAME"
        log "INFO" "Hostname from environment: $hostname"
    else
        hostname=$(hostname -f)
        log "INFO" "Hostname from system: $hostname"
    fi

    if [[ -z "$hostname" ]]; then
        log "ERROR" "Could not determine hostname"
        return 1
    fi

    echo "$hostname"
}

# CheckMK Downtime setzen
set_downtime() {
    local hostname="$1"
    local web_response

    log "INFO" "Setting downtime for host: $hostname (Duration: ${DOWNTIME_MINUTES} minutes)"

    # Web-Interface API-Call
    web_response=$(curl --connect-timeout 10 \
        --max-time 30 \
        --silent \
        --show-error \
        --insecure \
        --data "_username=$CHECKMK_USER" \
        --data "_secret=$CHECKMK_SECRET" \
        --data "_transid=-1" \
        --data "_do_confirm=yes" \
        --data "_do_actions=yes" \
        --data "host=$hostname" \
        --data "_down_from_now=yes" \
        --data "_down_minutes=$DOWNTIME_MINUTES" \
        --data "_down_comment=Automatic_downtime_$(hostname)_$(date +%Y%m%d_%H%M%S)" \
        "$CHECKMK_URL/check_mk/view.py?view_name=hoststatus" 2>&1) || {
        log "ERROR" "Web-Interface call failed: $web_response"
        return 1
    }

    # Fehler-Prüfung
    if echo "$web_response" | grep -q "<div class=error>"; then
        log "ERROR" "CheckMK reported an error: $web_response"
        return 1
    fi

    log "INFO" "Downtime successfully set"
    return 0
}

# Test-Modus
test_mode() {
    echo "=== CheckMK Downtime Service Test ==="
    echo "Configuration file: $CONFIG_FILE"
    echo "CheckMK URL: $CHECKMK_URL"
    echo "CheckMK User: $CHECKMK_USER"
    echo "Downtime Duration: $DOWNTIME_MINUTES minutes"
    echo "Hostname File: $HOSTNAME_FILE"

    local hostname
    hostname=$(get_hostname) || exit 1
    echo "Detected Hostname: $hostname"

    echo ""
    echo "Test completed successfully!"
    exit 0
}

# Hauptfunktion
main() {
    case "${1:-}" in
        --test)
            test_mode
            ;;
        --check-hostname)
            get_hostname
            exit 0
            ;;
        --help)
            echo "Usage: $0 [--test|--check-hostname|--help]"
            echo "  --test           Run configuration test"
            echo "  --check-hostname Show detected hostname"
            echo "  --help           Show this help"
            exit 0
            ;;
        "")
            # Normal operation
            local hostname
            hostname=$(get_hostname) || exit 1
            set_downtime "$hostname" || exit 1
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Script ausführen
main "$@"