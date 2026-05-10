# Generate short project codenames, for example DH-09.
codename() {
  local count="${1:-1}"
  local letters="ABCDEFGHJKMNPQRSTUVWXYZ"
  local digits="23456789"

  if ! [[ "$count" == <-> ]] || (( count < 1 )); then
    print -u2 "usage: codename [count]"
    return 1
  fi

  for _ in {1..$count}; do
    printf "%s%s-%s%s\n" \
      "${letters[$(( RANDOM % ${#letters} + 1 ))]}" \
      "${letters[$(( RANDOM % ${#letters} + 1 ))]}" \
      "${digits[$(( RANDOM % ${#digits} + 1 ))]}" \
      "${digits[$(( RANDOM % ${#digits} + 1 ))]}"
  done
}
