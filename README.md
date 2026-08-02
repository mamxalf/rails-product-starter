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

## Runtime Configuration

Mail uses `MAILER_FROM`, `APP_HOST`, and `APP_PROTOCOL`.

Solid Queue names used by this app: `default`, `mailers`, `notifications`, and
`low_priority`.

S3-compatible Active Storage can use the documented `S3_ACCESS_KEY_ID`,
`S3_SECRET_ACCESS_KEY`, `S3_REGION`, `S3_BUCKET`, `S3_ENDPOINT`, and
`S3_FORCE_PATH_STYLE` env vars in `config/storage.yml`.
