# EireaNet Public Assets

Static files — images and icons — for EireaNet, Inc. public-facing sites and applications.

Everything in this repository is intended to be served publicly and linked by URL.

> **This repository is public.** Anything committed here is readable by anyone, permanently, and
> remains in the git history after deletion. Do not commit anything that is not meant to be
> published.

---

## Layout
```
images/<FORMAT>/<YYYY>/<MM>/<filename>
```
- `<FORMAT>` — the file extension as spelled in this repository: `PNG`, `SVG`, `JPG`, `Gif`,
  `webp`, `jfif`, `JSON`. These are case-sensitive when served; match the existing spelling.
- `<YYYY>/<MM>` — the year and zero-padded month the file was **added**. Files are not moved to a
  new folder when they are reused later.
- No per-project subfolders.

### Naming
Lowercase, hyphen-separated, no spaces: `alerts-teal.png`. Where a file comes in variants, the
variant goes last: `patching-teal.png`, `patching-light.png`.

Some older files predate this (names with spaces or mixed case). They are left as they are, since
renaming breaks anything already linking to them. New files follow the convention.

---

## Adding and removing

**Adding.** Place the file under `images/<FORMAT>/<YYYY>/<MM>/` for the current month, using a
lowercase hyphenated name. After pushing, confirm with `git ls-tree` rather than by loading the
raw URL.

**Removing.** Files here may be linked by live pages, by messages already sent, or fetched at
build time, so a removal or rename can break something with no warning. Check what references a
file before touching it.

Deleting a file does not remove it from the git history.
