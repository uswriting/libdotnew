# lib.new

A simple CLI tool to create modern JavaScript/TypeScript libraries with best practices.

## Usage

```bash
curl https://lib.new | bash
```

## Features

- Creates JavaScript or TypeScript libraries
- Configures build tools with esbuild
- Sets up testing with Vitest
- Configures linting and formatting with Biome
- Supports npm, yarn, pnpm, and bun
- Optional git initialization
- Cross-platform support options

## Project Structure

```
your-library/
├── src/             # Source code
├── tests/           # Test files
├── package.json     # Project configuration
├── biome.json       # Formatting/linting config
├── build.js/ts      # Build script
└── tsconfig.json    # TypeScript config (if applicable)
```

## License

MIT