#!/bin/bash
#
# Pretty-print the keybindings defined in tmux.conf. Adapted from omarchy's
# omarchy-menu-tmux-keybindings — the Wayland/walker menu mode is removed;
# this always prints to stdout. Uses gawk for match() array captures.

config_file="${TMUX_CONF:-$HOME/.config/tmux/tmux.conf}"

while (($#)); do
  case "$1" in
    --config)
      shift
      config_file="$1"
      ;;
    *)
      config_file="$1"
      ;;
  esac
  shift
done

if [[ ! -f $config_file ]]; then
  echo "tmux config not found: $config_file" >&2
  exit 1
fi

gawk '
function trim(value) {
  gsub(/^[ \t]+|[ \t]+$/, "", value)
  return value
}

function key_part_text(part, is_modifier, part_count) {
  gsub(/^\\/, "", part)

  if (is_modifier && part == "C") return "CTRL"
  if (is_modifier && part == "M") return "ALT"
  if (is_modifier && part == "S") return "SHIFT"
  if (part == "Space") return "SPACE"
  if (part == "BSpace") return "BACKSPACE"
  if (part == "BTab") return "SHIFT + TAB"
  if (part == "PPage") return "PAGE UP"
  if (part == "NPage") return "PAGE DOWN"
  if (part == "DC") return "DELETE"
  if (part == "IC") return "INSERT"
  if (!is_modifier && part ~ /^[a-z]$/) return part
  if (!is_modifier && part ~ /^[A-Z]$/) return "SHIFT + " tolower(part)

  return toupper(part)
}

function key_text(key, parts, count, i, part, text) {
  gsub(/\\/, "", key)

  # Special-case the Hyper chord — Caps Lock-as-Hyper sends C-M-<letter>
  # after macOS strips Cmd and Alacritty drops Shift in legacy mode.
  if (key ~ /^C-M-[a-zA-Z]$/) {
    sub(/^C-M-/, "", key)
    return "HYPER + " tolower(key)
  }

  count = split(key, parts, "-")
  text = ""

  for (i = 1; i <= count; i++) {
    part = key_part_text(parts[i], i < count, count)
    text = text (text == "" ? "" : " + ") part
  }

  return text
}

function table_text(table) {
  if (table == "copy-mode-vi") return "COPY MODE"
  if (table == "copy-mode") return "COPY MODE"
  if (table == "prefix") return "PREFIX"

  gsub(/-/, " ", table)
  return toupper(table)
}

function pretty_command(command) {
  gsub(/\\;/, ";", command)
  gsub(/[{}]/, "", command)
  gsub(/^[ \t]+|[ \t]+$/, "", command)
  gsub(/[ \t]+/, " ", command)
  return command
}

function command_action(command, normalized, target) {
  normalized = pretty_command(command)

  # Hidden — internal mechanics, not useful in a cheat sheet
  if (normalized ~ /^send-prefix/) return "__SKIP__"
  if (normalized ~ /keybindings\.sh/) return "__SKIP__"

  if (normalized ~ /^send(-keys)? -X begin-selection/) return "Begin selection"
  if (normalized ~ /^send(-keys)? -X copy-selection-and-cancel/) return "Copy selection"
  if (normalized ~ /^copy-mode/) return "Enter copy mode"
  if (normalized ~ /^source-file/) return "Reload config"
  if (normalized ~ /^split-window -v/) return "Split pane vertically"
  if (normalized ~ /^split-window -h/) return "Split pane horizontally"
  if (normalized ~ /^kill-pane/) return "Kill pane"
  if (normalized ~ /^select-pane -L/) return "Focus pane left"
  if (normalized ~ /^select-pane -R/) return "Focus pane right"
  if (normalized ~ /^select-pane -U/) return "Focus pane up"
  if (normalized ~ /^select-pane -D/) return "Focus pane down"
  if (normalized ~ /^resize-pane -L/) return "Resize pane left"
  if (normalized ~ /^resize-pane -R/) return "Resize pane right"
  if (normalized ~ /^resize-pane -U/) return "Resize pane up"
  if (normalized ~ /^resize-pane -D/) return "Resize pane down"
  if (normalized ~ /^swap-pane -t "?left-of"?/) return "Move pane left"
  if (normalized ~ /^swap-pane -t "?right-of"?/) return "Move pane right"
  if (normalized ~ /^swap-pane -t "?up-of"?/) return "Move pane up"
  if (normalized ~ /^swap-pane -t "?down-of"?/) return "Move pane down"
  if (normalized ~ /^swap-pane -U/) return "Move pane left"
  if (normalized ~ /^swap-pane -D/) return "Move pane right"
  if (normalized ~ /rename-window/) return "Rename window"
  if (normalized ~ /^new-window/) return "New window"
  if (normalized ~ /^kill-window/) return "Kill window"

  if (match(normalized, /^select-window -t ([^ ;]+)/, target)) {
    gsub(/^:=?/, "", target[1])

    if (target[1] == "-1") return "Previous window"
    if (target[1] == "+1") return "Next window"

    return "Switch to window " target[1]
  }

  if (normalized ~ /^swap-window -t -1/) return "Move window left"
  if (normalized ~ /^swap-window -t \+1/) return "Move window right"
  if (normalized ~ /rename-session/) return "Rename session"
  if (normalized ~ /^new-session/) return "New session"
  if (normalized ~ /^kill-session/) return "Kill session"
  if (normalized ~ /^switch-client -p/) return "Previous session"
  if (normalized ~ /^switch-client -n/) return "Next session"

  return normalized
}

function add_record(combo, action, key, i) {
  if (action == "__SKIP__") return
  if (!(current_section in section_seen)) {
    section_order[++section_count] = current_section
    section_seen[current_section] = 1
  }

  key = current_section SUBSEP action
  if (key in action_index) {
    i = action_index[key]
    section_combos[current_section, i] = section_combos[current_section, i] " / " combo
  } else {
    i = ++section_size[current_section]
    action_index[key] = i
    section_combos[current_section, i] = combo
    section_actions[current_section, i] = action
  }
}

function parse_bind(line, words, count, i, table, global, key, command, combo, action) {
  count = split(line, words, /[ \t]+/)
  i = 2
  table = "prefix"
  global = 0

  while (i <= count && words[i] ~ /^-/) {
    if (words[i] == "-n") {
      global = 1
      i++
    } else if (words[i] == "-T") {
      table = words[i + 1]
      i += 2
    } else if (words[i] == "-r") {
      i++
    } else {
      i++
    }
  }

  key = words[i]
  i++

  command = ""
  for (; i <= count; i++) {
    command = command (command == "" ? "" : " ") words[i]
  }

  if (key == "" || command == "") return

  if (global) {
    combo = key_text(key)
  } else if (table == "prefix") {
    combo = "PREFIX + " key_text(key)
  } else {
    combo = table_text(table) " + " key_text(key)
  }

  action = command_action(command)
  add_record(combo, action)
}

BEGIN {
  prefix = "C-b"
  prefix2 = ""
  current_section = "General"
  section_count = 0
}

{
  raw = $0
  line = trim(raw)

  if (line == "") next

  if (line ~ /^#/) {
    # Treat any "# Word..." line as a potential section header.
    header = line
    sub(/^#[ \t]*/, "", header)
    if (header ~ /^[A-Z]/) current_section = header
    next
  }

  if (line ~ /^(set|set-option|setw|set-window-option)[ \t]/) {
    word_count = split(line, words, /[ \t]+/)

    for (i = 2; i <= word_count; i++) {
      if (words[i] == "prefix") prefix = words[i + 1]
      if (words[i] == "prefix2") prefix2 = words[i + 1]
    }

    next
  }

  if (line ~ /^(bind|bind-key)[ \t]/) parse_bind(line)
}

END {
  prefix_description = key_text(prefix)

  if (prefix2 != "" && prefix2 != "None") {
    prefix_description = prefix_description " / " key_text(prefix2)
  }

  printf "PREFIX → %s\n", prefix_description

  # compute max action width for alignment
  max_w = 0
  for (s = 1; s <= section_count; s++) {
    section = section_order[s]
    for (r = 1; r <= section_size[section]; r++) {
      w = length(section_actions[section, r])
      if (w > max_w) max_w = w
    }
  }

  for (s = 1; s <= section_count; s++) {
    section = section_order[s]
    printf "\n── %s ──\n", section
    for (r = 1; r <= section_size[section]; r++) {
      printf "  %-*s → %s\n", max_w, section_actions[section, r], section_combos[section, r]
    }
  }
}
' "$config_file"
