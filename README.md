# Rails Product Starter

## Quality

Run the full local gate before opening or merging a pull request:

```bash
bin/quality
```

Frontend checks are also available individually:

```bash
pnpm run check
pnpm run lint
pnpm run format:check
pnpm run test
pnpm run test:e2e
```

## Git hooks

Lefthook is optional. `bin/quality` and CI remain authoritative.

Install hooks after dependencies are installed:

```bash
pnpm exec lefthook install
```

Disable hooks:

```bash
pnpm exec lefthook uninstall
```

Skip hooks only for emergencies:

```bash
LEFTHOOK=0 git commit -m "message"
LEFTHOOK=0 git push
```

Run the skipped checks before opening or merging a pull request. If a hook cannot
find Ruby or pnpm commands, run it from the repository root after installing
dependencies with `bundle install` and `pnpm install`.
