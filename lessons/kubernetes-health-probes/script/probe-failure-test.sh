set -uo pipefail

NS="${NS:-default}"
APP_LABEL="app=orders-api"
SERVICE="orders-api-service"
PG_STS="postgres"
PG_POD="postgres-0"

if [ -t 1 ]; then
  BOLD=$'\033[1m'; RESET=$'\033[0m'
  RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
  BLUE=$'\033[34m'; MAGENTA=$'\033[35m'; CYAN=$'\033[36m'
else
  BOLD=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""
fi


k() { kubectl -n "$NS" "$@"; }

title() { printf '\n%s==== %s ====%s\n' "$BOLD" "$*" "$RESET"; }
step()  { printf '\n%s> %s%s\n' "$BOLD" "$*" "$RESET"; }
info()  { printf '  %s\n' "$*"; }
ok()    { printf '  %s%s%s\n' "$GREEN" "$*" "$RESET"; }
fail()  { printf '\n%sERROR: %s%s\n' "$RED" "$*" "$RESET" >&2; exit 1; }

wait_for_enter() {
  if [ "${AUTO:-0}" = "1" ]; then
    sleep 3
  else
    printf '\n  Press Enter to start %s...' "$1"
    read -r _
  fi
}

start_clock() { START="$(date +%s)"; }
elapsed()     { echo $(( $(date +%s) - START )); }

stamp() { printf '  [+%3ss] %s%-9s %s%s\n' "$(elapsed)" "$2" "$1" "$3" "$RESET"; }

cleanup() {
  if [ -n "${DEBUG_POD:-}" ]; then
    k delete pod "$DEBUG_POD" --now --ignore-not-found >/dev/null 2>&1
  fi
  if [ "${PG_SCALED_DOWN:-0}" = "1" ]; then
    printf '\n  Restoring PostgreSQL to 1 replica...\n'
    k scale statefulset "$PG_STS" --replicas=1 >/dev/null 2>&1
  fi
  if [ -n "${SEEN_EVENTS:-}" ]; then
    rm -f "$SEEN_EVENTS"
  fi
}
trap cleanup EXIT
trap 'exit 130' INT TERM

app_pod_name() { k get pod -l "$APP_LABEL" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null; }
app_ready()    { k get pod "$POD" -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null; }
app_restarts() { k get pod "$POD" -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null; }
pg_ready()     { k get pod "$PG_POD" -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null; }

pod_row() { k get pod "$1" --no-headers 2>/dev/null || echo "$1   (no Pod)"; }

pod_key() {
  local row restarts
  row="$(pod_row "$1" | awk '{print $2, $3}')"
  restarts="$(k get pod "$1" -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null)"
  echo "$row/$restarts"
}

endpoint_row() {
  k get endpointslices -l "kubernetes.io/service-name=$SERVICE" --no-headers \
    -o custom-columns='ADDRESSES:.endpoints[*].addresses,READY:.endpoints[*].conditions.ready' 2>/dev/null
}

show_endpoint_status() {
  local ip ready
  ip="$(k get endpointslices -l "kubernetes.io/service-name=$SERVICE" \
        -o jsonpath='{.items[0].endpoints[0].addresses[0]}' 2>/dev/null)"
  ready="$(k get endpointslices -l "kubernetes.io/service-name=$SERVICE" \
        -o jsonpath='{.items[0].endpoints[0].conditions.ready}' 2>/dev/null)"
  if [ "$ready" = "true" ]; then
    printf '  %sEndpointSlice: Pod IP %s  READY=true  -> the Service sends traffic to this Pod.%s\n' \
      "$BOLD$BLUE" "${ip:-?}" "$RESET"
  else
    printf '  %sEndpointSlice: Pod IP %s  READY=%s  -> the Service sends no traffic to this Pod.%s\n' \
      "$BOLD$BLUE" "${ip:-?}" "${ready:-false}" "$RESET"
  fi
}

event_rows() {
  k get events -o jsonpath='{range .items[*]}{.type}{"\t"}{.reason}{"\t"}{.count}{"\t"}{.involvedObject.name}{"\t"}{.message}{"\n"}{end}' 2>/dev/null \
    | awk -F'\t' -v pod="$POD" '($2 == "Unhealthy" && $4 == pod) || ($2 == "Killing" && $4 !~ /^node-debugger/)'
}

mark_events_seen() { event_rows > "$SEEN_EVENTS" || true; }

event_color() {
  case "$1" in
    *"Liveness probe"*)  printf '%s' "$RED" ;;
    *"Readiness probe"*) printf '%s' "$YELLOW" ;;
    *"Startup probe"*)   printf '%s' "$MAGENTA" ;;
    *)                   printf '%s' "$BOLD$RED" ;;
  esac
}

print_new_events() {
  local new type reason count object message text
  new="$(event_rows | grep -Fxv -f "$SEEN_EVENTS" || true)"
  [ -z "$new" ] && return
  while IFS=$'\t' read -r type reason count object message; do
    text="$(printf '%-8s %-10s %-3s %-28s %s' "$type" "$reason" "$count" "$object" "$message")"
    stamp "EVENT" "$(event_color "$message")" "$text"
    case "$message" in
      *"Liveness probe failed"*)  SAW_LIVENESS_FAIL=1 ;;
      *"Readiness probe failed"*) SAW_READINESS_FAIL=1 ;;
    esac
  done <<< "$new"
  printf '%s\n' "$new" >> "$SEEN_EVENTS"
}

is_ready()          { [ "$(app_ready)" = "true" ]; }
is_not_ready()      { [ "$(app_ready)" != "true" ]; }
has_restarted()     { local r; r="$(app_restarts)"; [ -n "$r" ] && [ "$r" -gt "$RESTARTS_BEFORE" ]; }
pg_is_ready()       { [ "$(pg_ready)" = "true" ]; }
both_probes_failed(){ [ "$SAW_LIVENESS_FAIL" = "1" ] && [ "$SAW_READINESS_FAIL" = "1" ]; }
never()             { return 1; }

LAST_APP="" LAST_PG="" LAST_EP=""
watch_loop() {
  local cond="$1" timeout="$2" desc="$3" on_timeout="$4" events="$5"
  local deadline=$(( $(date +%s) + timeout ))
  local key ep finished
  while true; do
    finished=0
    if [ "$cond" != "both_probes_failed" ] && "$cond"; then finished=1; fi

    key="$(pod_key "$POD")"
    if [ "$key" != "$LAST_APP" ]; then stamp "POD" "$BOLD$CYAN" "$(pod_row "$POD")"; LAST_APP="$key"; fi

    if [ "$SHOW_PG" = "1" ]; then
      key="$(pod_key "$PG_POD")"
      if [ "$key" != "$LAST_PG" ]; then stamp "POD" "$CYAN" "$(pod_row "$PG_POD")"; LAST_PG="$key"; fi
    fi

    if [ "$SHOW_EP" = "1" ]; then
      ep="$(endpoint_row)"
      if [ "$ep" != "$LAST_EP" ]; then stamp "ENDPOINT" "$BLUE" "$ep"; LAST_EP="$ep"; fi
    fi

    case "$events" in
      show) print_new_events ;;
      hide) mark_events_seen ;;
      later) ;;
    esac

    if [ "$cond" = "both_probes_failed" ] && both_probes_failed; then finished=1; fi

    if [ "$finished" = "1" ]; then ok "-> $desc (+$(elapsed)s)"; return 0; fi
    if [ "$(date +%s)" -ge "$deadline" ]; then
      [ "$on_timeout" = "ok" ] && return 0
      fail "Timed out after ${timeout}s waiting for: $desc"
    fi
    sleep 2
  done
}

title "Checking the setup"

command -v kubectl >/dev/null 2>&1 || fail "kubectl is not installed."
kubectl cluster-info >/dev/null 2>&1 || fail "kubectl can't connect to the cluster."

POD="$(app_pod_name)"
[ -n "$POD" ] || fail "No Orders API Pod found in namespace '$NS'. Deploy app.yaml first."
k get statefulset "$PG_STS" >/dev/null 2>&1 || fail "No PostgreSQL StatefulSet found. Deploy postgres.yaml first."

kubectl auth can-i create pods -n "$NS" >/dev/null 2>&1 \
  || fail "You need permission to create Pods (for the kubectl debug Pod)."

info "Waiting for the Orders API and PostgreSQL to be ready..."
k wait --for=condition=Ready "pod/$POD" --timeout=180s >/dev/null || fail "The Orders API Pod is not ready."
k wait --for=condition=Ready "pod/$PG_POD" --timeout=180s >/dev/null || fail "The PostgreSQL Pod is not ready."

NODE="$(k get pod "$POD" -o jsonpath='{.spec.nodeName}')"
ok "Orders API Pod: $POD (node: $NODE)"
ok "PostgreSQL Pod: $PG_POD"

SEEN_EVENTS="$(mktemp)"

title "TEST 1: The Orders API gets stuck"

info "The script pauses the Orders API process with SIGSTOP."
info "The process stays alive, but it stops answering requests."
info "Expected: readiness fails -> Pod 0/1, liveness fails -> container restarts."

SHOW_PG=0 SHOW_EP=0
SAW_LIVENESS_FAIL=0 SAW_READINESS_FAIL=0
LAST_APP="" LAST_PG="" LAST_EP=""
RESTARTS_BEFORE="$(app_restarts)"
mark_events_seen

step "Pausing the Orders API process from the node"
out="$(k debug "node/$NODE" --image=busybox --profile=sysadmin -- chroot /host pkill -STOP -f app.jar 2>&1)" \
  || fail "kubectl debug failed: $out"
DEBUG_POD="$(printf '%s' "$out" | grep -o 'node-debugger-[^ ]*' | head -1)"
[ -n "$DEBUG_POD" ] || fail "Could not find the debug Pod name in: $out"

phase=""
for _ in $(seq 1 60); do
  phase="$(k get pod "$DEBUG_POD" -o jsonpath='{.status.phase}' 2>/dev/null)"
  [ "$phase" = "Succeeded" ] && break
  if [ "$phase" = "Failed" ]; then
    k logs "$DEBUG_POD" 2>/dev/null
    fail "Could not pause the Orders API. Your cluster may block privileged Pods."
  fi
  sleep 2
done
[ "$phase" = "Succeeded" ] || fail "The debug Pod did not finish. Check: kubectl -n $NS describe pod $DEBUG_POD"
k delete pod "$DEBUG_POD" --now >/dev/null 2>&1
DEBUG_POD=""

start_clock
ok "Orders API paused."

step "Checking that the probes are failing"
watch_loop both_probes_failed 60 "The liveness and readiness probes are failing" fail show

step "Checking the Pod status"
watch_loop is_not_ready 60 "The readiness probe marked the Pod as not ready (0/1)" fail later

step "Waiting for the liveness probe to restart the container"
watch_loop has_restarted 120 "The liveness probe restarted the container" fail show

step "Waiting for the Orders API to start again"
watch_loop is_ready 180 "The Orders API is running and ready again (1/1)" fail hide

title "TEST 2: PostgreSQL stops"

info "The script stops PostgreSQL, keeps it down for a while, then starts it again."
info "Expected: readiness fails -> Pod 0/1, no restart, liveness keeps passing."
wait_for_enter "Test 2"

SHOW_PG=1 SHOW_EP=1
LAST_APP="" LAST_PG="" LAST_EP=""
mark_events_seen

step "Stopping PostgreSQL (scaling to 0 replicas)"
start_clock
k scale statefulset "$PG_STS" --replicas=0 >/dev/null || fail "Could not scale PostgreSQL to 0."
PG_SCALED_DOWN=1

watch_loop is_not_ready 90 "The readiness probe failed. The Pod is not ready (0/1)" fail show
show_endpoint_status

step "Keeping PostgreSQL down for 20 more seconds"
watch_loop never 20 "" ok show

step "Starting PostgreSQL again (scaling to 1 replica)"
k scale statefulset "$PG_STS" --replicas=1 >/dev/null || fail "Could not scale PostgreSQL to 1."
PG_SCALED_DOWN=0
watch_loop pg_is_ready 120 "PostgreSQL is running and ready (1/1)" fail show

step "Waiting for the Orders API to be ready again"
watch_loop is_ready 180 "The readiness probe passed. The Pod is ready again (1/1)" fail show
show_endpoint_status

title "Done"
info "Both tests are complete. The Orders API and PostgreSQL are running again."