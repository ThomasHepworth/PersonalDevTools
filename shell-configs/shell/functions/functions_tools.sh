function setup_vscode_settings() {
  local flag="${1:-}"
  local here
  here="$(pwd)"
  local vscode_dir=".vscode"
  local settings_file="${vscode_dir}/settings.json"
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"

  # Git root check (unless --force)
  if [[ "$flag" != "--force" && ! -d .git ]]; then
    printf '%s\n' \
      "This script should be run from the root of a git repository." \
      "Use --force to override this check."
    return 1
  fi

  # Create .vscode directory if needed
  if [[ ! -d "$vscode_dir" ]]; then
    mkdir -p "$vscode_dir" || {
      echo "Failed to create ${here}/${vscode_dir}"
      return 1
    }
  fi

  # Desired settings (VS Code accepts JSON with comments)
  read -r -d '' desired_json <<'JSON'
{
  // === Editor ergonomics ===
  "editor.tabSize": 4,
  "editor.insertSpaces": true,
  "editor.rulers": [
    100
  ],
  "editor.renderWhitespace": "selection",
  "editor.wordWrap": "on",
  "editor.minimap.enabled": false,
  "breadcrumbs.enabled": true,

  // === Files & whitespace hygiene ===
  "files.eol": "\n",

  // === Explorer/Search noise reduction ===
  "files.exclude": {
    "**/.DS_Store": true,
    "**/Thumbs.db": true,
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/coverage": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/coverage": true
  },

  // === Git quality-of-life ===
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.pruneOnFetch": true,
  "git.rebaseWhenSync": true,
  "git.mergeEditor": true,

  // === Terminal ===
  "terminal.integrated.copyOnSelection": true,
  "terminal.integrated.shellIntegration.enabled": true,
  "terminal.integrated.profiles.osx": {
    "Copilot (clean bash)": {
      "path": "/bin/bash",
      "args": ["--noprofile", "--norc"]
    }
  },
  "terminal.integrated.defaultProfile.osx": "Copilot (clean bash)",

  // === Security & telemetry ===
  "security.workspace.trust.enabled": true,
  "telemetry.telemetryLevel": "off",

  // === Workbench ===
  "workbench.startupEditor": "newUntitledFile",
  "workbench.editor.enablePreview": true,

  // === Ruff (VS Code extension) ===
  // === Python-specific overrides ===
  "[python]": {
    "editor.codeActionsOnSave": {
      // Run Ruff auto-fixes on every save
      "source.fixAll.ruff": "always",
      // Let Ruff organise imports on save (recommended if using Ruff's I-rules)
      "source.organizeImports.ruff": "always"
    },
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true
  },

  // === Jupyter ===
  "jupyter.notebookFileRoot": "${workspaceFolder}",

  // === Python analysis ===
  "python.analysis.extraPaths": [
    "${workspaceFolder}"
  ],

  // === Python testing ===
  "python.testing.pytestEnabled": true,
  "python.testing.unittestEnabled": false,
  "python.testing.pytestArgs": [
    "-q",        // quiet, one-shot
    "-ra"        // show extra summary for failed/skipped
  ]
}
JSON

  # If settings exist and not forcing, avoid clobbering.
  # We detect "already configured" by checking for the Ruff on-save key.
  if [[ -f "$settings_file" && "$flag" != "--force" ]]; then
    if grep -q '"source\.fixAll\.ruff"' "$settings_file"; then
      echo "VS Code settings already configured at ${here}/${settings_file}"
      return 0
    else
      echo "A ${settings_file} already exists but doesn't contain Ruff on-save settings."
      echo "Run again with --force to overwrite (a backup will be created)."
      return 1
    fi
  fi

  # Backup if overwriting
  if [[ -f "$settings_file" && "$flag" == "--force" ]]; then
    cp -p "$settings_file" "${settings_file}.bak.${ts}" && \
      echo "Backed up existing settings to ${here}/${settings_file}.bak.${ts}"
  fi

  # Write (overwrite atomically)
  local tmpfile
  tmpfile="$(mktemp)" || {
    echo "Failed to create temporary file"
    return 1
  }
  printf '%s\n' "$desired_json" > "$tmpfile" || {
    echo "Failed to write settings content to temporary file"
    rm -f "$tmpfile"
    return 1
  }
  mv "$tmpfile" "$settings_file" || {
    echo "Failed to write ${here}/${settings_file}"
    rm -f "$tmpfile"
    return 1
  }

  if [[ "$flag" == "--force" ]]; then
    echo "Forcing VS Code settings setup."
  fi
  echo "VS Code settings configured at ${here}/${settings_file}"
  return 0
}