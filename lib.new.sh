#!/usr/bin/env bash
set -euo pipefail

# --- ANSI Colors and Styles (Unique Branding) ---
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
UNDERLINE="\033[4m"
FG_PRIMARY="\033[38;5;141m"    # A distinctive purple
FG_ACCENT="\033[38;5;45m"      # A vibrant cyan
FG_INFO="\033[38;5;117m"       # A fresh green for info messages
FG_SUCCESS="\033[92m"
FG_WARNING="\033[38;5;214m"    # A bold yellow-orange for warnings
FG_ERROR="\033[38;5;196m"      # A clear red for errors
FG_LIGHT="\033[38;5;250m"      # A light gray for unselected text
BOLD_BRIGHT_WHITE="\033[1;97m"

# --- Emoji Icons (New Branding) ---
EMOJI_ROCKET="🚀"
EMOJI_SPARKLE="💫"
EMOJI_GROWTH="📈"
EMOJI_BACK="←"

# --- Global State Variables for Library Creation ---
PKG_NAME=""
DIR_NAME=""
LANGUAGE=""
PKG_MANAGER=""
USE_GIT=""
IS_CROSS_PLATFORM=""
INSTALL_DEPS=""

TOTAL_STEPS=6

# --- Utility Functions ---
get_terminal_width() {
  tput cols 2>/dev/null || echo 80
}

draw_separator() {
  local width line=""
  width=$(get_terminal_width)
  for (( i=0; i < width; i++ )); do
    line+="─"
  done
  echo -e "${FG_LIGHT}${line}${RESET}" >&2
}

draw_header() {
  echo -e "" >&2
  echo -e "${EMOJI_ROCKET} ${BOLD}Welcome to lib.new by US Writing Corporation!${RESET}" >&2
  echo -e "${FG_LIGHT}GitHub: https://github.com/uswriting/libdotnew | Website: https://uswriting.co${RESET}" >&2
  echo -e "${EMOJI_SPARKLE} Let's create your JavaScript/TypeScript library." >&2
  echo -e "" >&2
  draw_separator
}

draw_step_indicator() {
  local step=$1
  echo -e "" >&2
  echo -e "${FG_LIGHT}╭${RESET} ${FG_PRIMARY}${BOLD}Create your JavaScript Library${RESET} ${FG_LIGHT}Step ${step} of ${TOTAL_STEPS}${RESET}" >&2
}

draw_history() {
  local step=$1
  if [[ $step -gt 1 && -n "$PKG_NAME" ]]; then
    echo -e "${FG_LIGHT}│${RESET}" >&2
    echo -e "${FG_LIGHT}├─ package: ${FG_PRIMARY}${PKG_NAME}${RESET}" >&2
  fi
  if [[ $step -gt 2 && -n "$LANGUAGE" ]]; then
    echo -e "${FG_LIGHT}│${RESET}" >&2
    echo -e "${FG_LIGHT}├─ lang: ${FG_ACCENT}${LANGUAGE}${RESET}" >&2
  fi
  if [[ $step -gt 3 && -n "$PKG_MANAGER" ]]; then
    echo -e "${FG_LIGHT}│${RESET}" >&2
    echo -e "${FG_LIGHT}├─ mgr: ${FG_ACCENT}${PKG_MANAGER}${RESET}" >&2
  fi
  if [[ $step -gt 4 && -n "$USE_GIT" ]]; then
    echo -e "${FG_LIGHT}│${RESET}" >&2
    echo -e "${FG_LIGHT}├─ git: ${FG_ACCENT}${USE_GIT}${RESET}" >&2
  fi
  if [[ $step -gt 5 && -n "$IS_CROSS_PLATFORM" ]]; then
    echo -e "${FG_LIGHT}│${RESET}" >&2
    echo -e "${FG_LIGHT}└─ cross: ${FG_ACCENT}${IS_CROSS_PLATFORM}${RESET}" >&2
  fi
}

# --- Input Functions ---
get_dir_input() {
  local default="./stellar-lib-001"
  local provided_dir="${1:-}"

  if [[ -n "$provided_dir" ]]; then
    # Use the provided directory name from argument
    DIR_NAME="$provided_dir"
    # Prepend "./" if missing
    if [[ "$DIR_NAME" != ./* ]]; then
      DIR_NAME="./$DIR_NAME"
    fi
    # Validate: directory must not already exist
    if [[ -d "$DIR_NAME" ]]; then
      echo -e "${FG_ERROR}${BOLD}Error:${RESET} Directory '${DIR_NAME}' already exists. Exiting." >&2
      exit 1
    fi
    # Derive package name from directory basename
    PKG_NAME=$(basename "$DIR_NAME")
    return
  fi

  clear
  draw_header
  draw_step_indicator 1 ${TOTAL_STEPS}
  draw_history 1
  echo -e "${FG_LIGHT}│${RESET}" >&2
  echo -e "${FG_LIGHT}╰─${RESET} ${BOLD_BRIGHT_WHITE}In which directory do you want to create your library? ${DIM}(also used as package name)${RESET}" >&2
  echo -ne "  ${FG_LIGHT}./${RESET}"
  read -r input <&2
  DIR_NAME=${input:-$default}
  # Prepend "./" if missing
  if [[ "$DIR_NAME" != ./* ]]; then
    DIR_NAME="./$DIR_NAME"
  fi
  # Validate: directory must not already exist
  if [[ -d "$DIR_NAME" ]]; then
    echo -e "${FG_ERROR}${BOLD}Error:${RESET} Directory '${DIR_NAME}' already exists. Exiting." >&2
    exit 1
  fi
  # Derive package name from directory basename
  PKG_NAME=$(basename "$DIR_NAME")
}

select_yes_no() {
  local prompt="$1" step="$2" footnote="${3:-}"
  local options=("Yes" "No") selected=0

  # Enable alternate screen buffer and hide cursor
  echo -e "\033[?1049h" >&2
  echo -e "\033[?25l" >&2

  display_yes_no() {
    clear >&2
    draw_header
    draw_step_indicator "$step" ${TOTAL_STEPS}
    draw_history "$step"
    echo -en "${FG_LIGHT}╰─${RESET} ${BOLD_BRIGHT_WHITE}${prompt}${RESET}" >&2
    echo "" >&2

    local indent
    indent="  " line="$indent"
    for i in "${!options[@]}"; do
      if [[ $i -eq $selected ]]; then
        line+=" ${FG_ACCENT}${BOLD}${UNDERLINE}${options[$i]}${RESET} "
      else
        line+=" ${FG_LIGHT}${options[$i]}${RESET} "
      fi
    done
    echo -e "$line" >&2
    [[ -n "$footnote" ]] && { echo -e ""; echo -e " ${DIM}${footnote}${RESET}" >&2; }
  }

  display_yes_no
  while true; do
    read -rsn1 key <&2
    if [[ $key == $'\x1b' ]]; then
      read -rsn2 key <&2
      if [[ $key == "[D" ]]; then
        ((selected--)); ((selected < 0)) && selected=1; display_yes_no
      elif [[ $key == "[C" ]]; then
        ((selected++)); ((selected > 1)) && selected=0; display_yes_no
      fi
    elif [[ $key == "" ]]; then
      # Restore cursor and disable alternate screen
      echo -e "\033[?25h" >&2
      echo -e "\033[?1049l" >&2
      break
    fi
  done
  printf "%s" "${options[$selected]}"
}

get_use_git_input() { USE_GIT=$(select_yes_no "Use git for version control?" "4"); }
get_cross_platform_input() { IS_CROSS_PLATFORM=$(select_yes_no "Is this a cross-platform library?" "5"); }
get_install_deps_input() { INSTALL_DEPS=$(select_yes_no "Install dependencies after setup?" "6"); }

select_menu() {
  local title="$1"
  local step="$2"
  local footnote="$3"
  shift 3
  local options=("$@")
  local selected=0

  # Enable alternate screen buffer and hide cursor
  echo -e "\033[?1049h" >&2
  echo -e "\033[?25l" >&2

  display_menu() {
    clear >&2
    draw_header
    draw_step_indicator "$step" ${TOTAL_STEPS}
    draw_history "$step"
    echo -e "${FG_LIGHT}╰─${RESET} ${BOLD_BRIGHT_WHITE}${title}${RESET}" >&2
    for i in "${!options[@]}"; do
      if [[ $i -eq $selected ]]; then
        if [[ "${options[$i]}" == "Go back" ]]; then
          echo -e "   ${FG_ACCENT}${EMOJI_BACK} ${UNDERLINE}${options[$i]}${RESET}" >&2
        else
          echo -e "   ${FG_ACCENT}● ${UNDERLINE}${options[$i]}${RESET}" >&2
        fi
      else
        if [[ "${options[$i]}" == "Go back" ]]; then
          echo -e "   ${FG_LIGHT}${EMOJI_BACK} ${options[$i]}${RESET}" >&2
        else
          echo -e "   ${FG_LIGHT}○ ${options[$i]}${RESET}" >&2
        fi
      fi
    done
    if [[ -n "$footnote" ]]; then
      echo -e "" >&2
      echo -e "   ${DIM}${footnote}${RESET}" >&2
    fi
  }

  display_menu
  while true; do
    read -rsn1 key <&2
    if [[ $key == $'\x1b' ]]; then  # Escape sequence
      read -rsn2 key <&2
      if [[ $key == "[A" ]]; then  # Up arrow
        ((selected--))
        ((selected < 0)) && selected=$((${#options[@]} - 1))
        display_menu
      elif [[ $key == "[B" ]]; then  # Down arrow
        ((selected++))
        ((selected >= ${#options[@]})) && selected=0
        display_menu
      fi
    elif [[ $key == "" ]]; then  # Enter
      # Restore cursor and disable alternate screen
      echo -e "\033[?25h" >&2
      echo -e "\033[?1049l" >&2
      break
    fi
  done
  printf "%s" "${options[$selected]}"
}

# --- Library Creation Functions ---
create_package_json() {
  local pkg_name="$1" language="$2" pkg_manager="$3"
  local ext="js" types_line="" export_types=""
  if [[ "$language" == "TypeScript" ]]; then
    ext="ts"
    types_line="  \"types\": \"dist/index.d.ts\","
    export_types=", \"types\": \"./dist/index.d.ts\""
  fi
  cat > package.json <<EOF
{
  "name": "${pkg_name}",
  "version": "0.0.1",
  "description": "generated by lib.new (US Writing Corporation)",
  "private": true,
  "type": "module",
  "main": "dist/index.js",
${types_line}
  "module": "dist/index.js",
  "exports": {
    "./biome": "./biome.json",
    ".": {
      "import": "./dist/index.js"${export_types}
    }
  },
  "sideEffects": false,
  "files": ["dist"],
  "scripts": {
    "build": "node build.${ext} && tsc --emitDeclarationOnly --outDir ./dist",
    "dev": "esbuild src/index.${ext} --bundle --format=esm --outdir=dist --watch",
    "test": "vitest run",
    "test:watch": "vitest",
    "format": "biome format --write",
    "lint": "biome lint --error-on-warnings --write",
    "prepublishOnly": "npm run build"
  },
  "keywords": [],
  "author": "",
  "license": "MIT"
}
EOF
}

create_tsconfig_files() {
  local cross_platform="$1"
  cat > tsconfig.json <<EOF
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "emitDeclarationOnly": true,
    "outDir": "dist"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

  cat > tsconfig.node.json <<EOF
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "lib": ["ESNext"],
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "types": ["node"]
  }
}
EOF

  if [[ "$cross_platform" =~ ^[Yy]$ ]]; then
    cat > tsconfig.web.json <<EOF
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "lib": ["ESNext", "DOM", "DOM.Iterable"],
    "types": []
  }
}
EOF
  fi
}

create_biome_config() {
  cat > biome.json <<EOF
{
  "\$schema": "https://biomejs.dev/schemas/1.9.4/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "ignore": ["tests"],
    "enabled": true,
    "rules": {
      "recommended": true
    }
  },
  "formatter": {
    "include": ["src/**/*.js", "src/**/*.ts", "tests/**/*.js", "tests/**/*.ts"],
    "ignore": ["node_modules/**/*.*", "dist/**/*.*"],
    "enabled": true,
    "indentWidth": 2,
    "indentStyle": "space"
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "double",
      "trailingCommas": "es5",
      "semicolons": "always"
    }
  }
}
EOF
}

create_build_script() {
  local language="$1" ext="js"
  [[ "$language" == "TypeScript" ]] && ext="ts"
  cat > "build.${ext}" <<EOF
// Build script for the library
import { build } from "esbuild";
import { existsSync, mkdirSync } from "node:fs";

if (!existsSync("./dist")) {
  mkdirSync("./dist");
}

console.log("🔨 Building library...");

try {
  await build({
    entryPoints: ["src/index.${ext}"],
    outdir: "dist",
    bundle: true,
    format: "esm",
    sourcemap: true,
    minify: false,
    platform: "neutral",
    target: "esnext"
  });
  console.log("✅ Build completed successfully!");
} catch (error) {
  console.error("❌ Build failed:", error);
  process.exit(1);
}
EOF
}

create_sample_files() {
  local language="$1" ext="js"
  [[ "$language" == "TypeScript" ]] && ext="ts"
  mkdir -p src
  if [[ "$language" == "TypeScript" ]]; then
    cat > src/index.ts <<EOF
/**
 * A simple greeting function
 * @param name The name to greet
 * @returns A greeting message
 */
export function greet(name: string): string {
  return \`Hello, \${name}!\`;
}

export * from "./utils";
EOF
    cat > src/utils.ts <<EOF
/**
 * Adds two numbers together
 * @param a First number
 * @param b Second number
 * @returns The sum of the two numbers
 */
export function add(a: number, b: number): number {
  return a + b;
}

/**
 * Formats a value as currency
 * @param value The value to format
 * @param currency The currency code (default: "USD")
 * @returns Formatted currency string
 */
export function formatCurrency(value: number, currency = "USD"): string {
  return new Intl.NumberFormat("en-US", { style: "currency", currency }).format(value);
}
EOF
  else
    cat > src/index.js <<EOF
/**
 * A simple greeting function
 * @param {string} name The name to greet
 * @returns {string} A greeting message
 */
export function greet(name) {
  return \`Hello, \${name}!\`;
}

export * from "./utils";
EOF
    cat > src/utils.js <<EOF
/**
 * Adds two numbers together
 * @param {number} a First number
 * @param {number} b Second number
 * @returns {number} The sum of the two numbers
 */
export function add(a, b) {
  return a + b;
}

/**
 * Formats a value as currency
 * @param {number} value The value to format
 * @param {string} [currency="USD"] The currency code
 * @returns {string} Formatted currency string
 */
export function formatCurrency(value, currency = "USD") {
  return new Intl.NumberFormat("en-US", { style: "currency", currency }).format(value);
}
EOF
  fi
}

create_test_files() {
  local language="$1" ext="js"
  [[ "$language" == "TypeScript" ]] && ext="ts"
  mkdir -p tests
  cat > vitest.config.${ext} <<EOF
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    include: ["tests/**/*.test.${ext}"],
    coverage: {
      reporter: ["text", "json", "html"]
    }
  }
});
EOF
  if [[ "$language" == "TypeScript" ]]; then
    cat > tests/utils.test.ts <<EOF
import { describe, it, expect } from "vitest";
import { add, formatCurrency } from "../src/utils";

describe("utils", () => {
  describe("add", () => {
    it("adds two positive numbers", () => {
      expect(add(1, 2)).toBe(3);
    });
    it("handles negative numbers", () => {
      expect(add(-1, 1)).toBe(0);
      expect(add(-1, -2)).toBe(-3);
    });
  });
  describe("formatCurrency", () => {
    it("formats USD by default", () => {
      expect(formatCurrency(1234.56)).toBe("\$1,234.56");
    });
    it("handles different currencies", () => {
      expect(formatCurrency(1234.56, "EUR")).toBe("€1,234.56");
    });
  });
});
EOF
  else
    cat > tests/utils.test.js <<EOF
import { describe, it, expect } from "vitest";
import { add, formatCurrency } from "../src/utils";

describe("utils", () => {
  describe("add", () => {
    it("adds two positive numbers", () => {
      expect(add(1, 2)).toBe(3);
    });
    it("handles negative numbers", () => {
      expect(add(-1, 1)).toBe(0);
      expect(add(-1, -2)).toBe(-3);
    });
  });
  describe("formatCurrency", () => {
    it("formats USD by default", () => {
      expect(formatCurrency(1234.56)).toBe("\$1,234.56");
    });
    it("handles different currencies", () => {
      expect(formatCurrency(1234.56, "EUR")).toBe("€1,234.56");
    });
  });
});
EOF
  fi
}

create_gitignore() {
  cat > .gitignore <<EOF
# Dependencies
node_modules
.pnp
.pnp.js

# Build output
dist
build
*.tsbuildinfo

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Test coverage
coverage

# Editor directories and files
.vscode/*
!.vscode/extensions.json
!.vscode/settings.json
.idea
.DS_Store
EOF
}

get_install_command() {
  local pkg_manager="$1" language="$2"
  local dev_deps="esbuild@0.25.1 vitest@3.0.9 @biomejs/biome@1.9.4"
  [[ "$language" == "TypeScript" ]] && dev_deps="$dev_deps typescript@5.8.2 @types/node@22.13.14"
  case "$pkg_manager" in
    "npm")  echo "npm install --save-dev $dev_deps" ;;
    "yarn") echo "yarn add --dev $dev_deps" ;;
    "pnpm") echo "pnpm add --save-dev $dev_deps" ;;
    "bun")  echo "bun add --dev $dev_deps" ;;
  esac
}

task_status() {
  local message="$1"
  local completed_message

  # Handle various verb transformations
  if [[ "$message" == *"Creating"* ]]; then
    completed_message="${message/Creating/Created}"
  elif [[ "$message" == *"Initializing"* ]]; then
    completed_message="${message/Initializing/Initialized}"
  elif [[ "$message" == *"Installing"* ]]; then
    completed_message="${message/Installing/Installed}"
  else
    # Generic fallback that handles the general case properly
    completed_message="${message%ing}ed"
  fi

  echo -ne "${BOLD_BRIGHT_WHITE}${message}...${RESET}"
  # Execute the command passed as the second argument
  eval "$2"
  local status=$?
  # Clear to the beginning of line and print completion message
  echo -ne "\r${BOLD_BRIGHT_WHITE}${completed_message}${RESET} "
  if [ $status -eq 0 ]; then
    echo -e "${FG_SUCCESS}✅${RESET}"
  else
    echo -e "${FG_ERROR}❌${RESET}"
    return 1
  fi
}

main() {
  # Check for directory name as first argument
  local provided_dir="${1:-}"

  # Step 1-6: Get all inputs with proper navigation between steps
  local current_step=1

  while [[ $current_step -le 6 ]]; do
    case $current_step in
      1)
        get_dir_input "$provided_dir"
        current_step=$((current_step + 1))
        ;;
      2)
        LANGUAGE=$(select_menu "Select language" "2" "Choose JavaScript or TypeScript" "JavaScript" "TypeScript" "Go back")
        if [[ "$LANGUAGE" == "Go back" ]]; then
          current_step=$((current_step - 1))
        else
          current_step=$((current_step + 1))
        fi
        ;;
      3)
        PKG_MANAGER=$(select_menu "Select package manager" "3" "Choose your package manager" "npm" "yarn" "pnpm" "bun" "Go back")
        if [[ "$PKG_MANAGER" == "Go back" ]]; then
          current_step=$((current_step - 1))
        else
          current_step=$((current_step + 1))
        fi
        ;;
      4)
        USE_GIT=$(select_yes_no "Use git for version control?" "4")
        current_step=$((current_step + 1))
        ;;
      5)
        IS_CROSS_PLATFORM=$(select_yes_no "Is this a cross-platform library?" "5")
        current_step=$((current_step + 1))
        ;;
      6)
        INSTALL_DEPS=$(select_yes_no "Install dependencies after setup?" "6")
        current_step=$((current_step + 1))
        ;;
    esac
  done

  # Final Summary
  clear
  draw_header
  echo -e "${BOLD_BRIGHT_WHITE}Library settings:${RESET}"
  echo -e "• Package: ${FG_PRIMARY}${PKG_NAME}${RESET}"
  echo -e "• Language: ${FG_ACCENT}${LANGUAGE}${RESET}"
  echo -e "• Package manager: ${FG_ACCENT}${PKG_MANAGER}${RESET}"
  echo -e "• Git: ${FG_ACCENT}${USE_GIT}${RESET}"
  echo -e "• Cross-platform: ${FG_ACCENT}${IS_CROSS_PLATFORM}${RESET}"
  echo -e "• Install dependencies: ${FG_ACCENT}${INSTALL_DEPS}${RESET}"
  draw_separator

  # Create library directory
  task_status "Creating library directory" "mkdir -p \"$DIR_NAME\""
  cd "$DIR_NAME" || { echo -e "${FG_ERROR}Failed to change to directory $DIR_NAME${RESET}"; exit 1; }

  # Create library files
  task_status "Creating package.json" "create_package_json \"$PKG_NAME\" \"$LANGUAGE\" \"$PKG_MANAGER\""
  task_status "Creating biome.json" "create_biome_config"
  task_status "Creating build script" "create_build_script \"$LANGUAGE\""
  task_status "Creating sample source files" "create_sample_files \"$LANGUAGE\""
  task_status "Creating test files" "create_test_files \"$LANGUAGE\""
  task_status "Creating .gitignore" "create_gitignore"

  # TypeScript-specific setup
  if [[ "$LANGUAGE" == "TypeScript" ]]; then
    task_status "Creating tsconfig files" "create_tsconfig_files \"$IS_CROSS_PLATFORM\""
  fi

  # Git initialization
  if [[ "${USE_GIT^^}" == "YES" ]]; then
    task_status "Initializing git repository" "git init > /dev/null"
  fi

  # Dependencies installation
  INSTALL_CMD=$(get_install_command "$PKG_MANAGER" "$LANGUAGE")
  if [[ "${INSTALL_DEPS^^}" == "YES" ]]; then
    task_status "Installing dependencies" "$INSTALL_CMD"
  else
    echo -e "${BOLD_BRIGHT_WHITE}To install dependencies later, run:${RESET}"
    echo -e "  ${FG_INFO}${INSTALL_CMD}${RESET}"
  fi

  # Next steps
  draw_separator
  echo -e "${BOLD_BRIGHT_WHITE}Next steps:${RESET}"
  echo -e "1. ${FG_INFO}cd ${DIR_NAME}${RESET}"
  echo -e "2. ${FG_INFO}npm run build${RESET}    # Build the library"
  echo -e "3. ${FG_INFO}npm run test${RESET}     # Run tests"
  echo -e "4. ${FG_INFO}npm run format${RESET}   # Format code with Biome"
}

main "$@"
