#!/bin/zsh
# Headless (no-remote-monitor), run this at login

function check_modifier_keys() {
  python -c 'import Cocoa; print(Cocoa.NSEvent.modifierFlags() == 0)'
}

function set_display_resolution() {
  local target_resolution="$1"
  local target_hz="$2"
  local target_color_depth="$3"
  local target_scaling="$4"
  local target_origin="$5"
  local target_degree="$6"
  local target_type="$7"

  local display_list
  display_list=$(displayplacer list)

  local persistent_id
  local found_type

  while IFS= read -r line; do
    if [[ "$line" == "Type: "* ]]; then
      local type="${line#*Type: }"
      if [[ "$type" == "$target_type" ]]; then
        found_type="$type" # Store the found type
        while IFS= read -r prev_line; do
          if [[ "$prev_line" == "Persistent screen id: "* ]]; then
            persistent_id="${prev_line#*Persistent screen id: }"
            break 2 # Break out of both loops
          fi
        done <<< "$(head -n $(($LINENO - 1)) <<< "$display_list")"
      fi
    fi
  done <<< "$display_list"

  if [[ -n "$persistent_id" ]]; then
    if $(check_modifier_keys); then
      displayplacer "id:$persistent_id res:$target_resolution hz:$target_hz color_depth:$target_color_depth scaling:$target_scaling origin:$target_origin degree:$target_degree"
    else
      echo "Modifier keys pressed. bypassing screen resolution command..."
    fi

    # Final display
    echo "Display Type: $found_type"
    echo "Persistent ID: $persistent_id"
    echo "Current Mode:"
    displayplacer list | grep "id:$persistent_id" -A 50 | grep " <-- current mode"
  else
    echo "Screen type '$target_type' not found"
  fi
}

# Add your usage here...

# Example usage for a MacBook built-in screen
# set_display_resolution "1920x1200" "60" "4" "on" "(0,0)" "0" "MacBook built in screen"

# Example usage for an external display (replace with actual values)
# set_display_resolution "2560x1440" "60" "4" "on" "(0,0)" "0" "External Display Type"
