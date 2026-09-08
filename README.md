# KJVOnly Data

Source data and generated publication artifacts used by the KJVOnly application and Resource Publishing CLI.

This repository contains Bible content, bundles, overlays, indexes, metadata, Strong's data, and other application Resources in the serialized formats used during publication.

Large generated data files are stored with **Git LFS**.

---

## Repository Purpose

This repository is the source-data side of the KJVOnly Resource publishing workflow.

Conceptually:

```text
KJVOnly Data
    ↓
Resource Publishing CLI
    ↓
Nostr + Blossom
    ↓
Published Resources
    ↓
KJVOnly Application
```

The repository contains the serialized Resource content that the publishing CLI consumes.

It does not contain the application runtime or publication implementation itself.

---

# Repository Organization

The repository root is the data root.

Data is organized by application domain and Resource category.

```text
kjvonly-data/
├── bible/
│   ├── chapters/
│   │   ├── content/
│   │   │   ├── kjv/
│   │   │   └── kjvs/
│   │   └── bundles/
│   │
│   ├── overlays/
│   │   ├── paragraphs/
│   │   │   └── bundles/
│   │   └── pericopes/
│   │       └── bundles/
│   │
│   ├── indexes/
│   │   └── bible/
│   │       └── bundles/
│   │
│   └── metadata/
│       └── booknames/
│           └── bundles/
│
└── strongs/
    └── definitions/
        └── bundles/
```

The general convention is:

```text
<domain>/
└── <resource-category>/
    ├── content/
    └── bundles/
```

Not every Resource category needs both directories.

---

# `content/`

`content/` contains individual serialized Resources intended to be published directly in Nostr events.

For example:

```text
bible/chapters/content/kjv/
├── 1_1.json.gz
├── 1_2.json.gz
└── ...
```

Each file represents one concrete Resource.

For Bible Chapters, filenames use:

```text
<book-id>_<chapter>.json.gz
```

Examples:

```text
1_1.json.gz
1_2.json.gz
43_3.json.gz
```

---

# `bundles/`

`bundles/` contains larger serialized Resources intended to be published through external object storage such as Blossom.

For example:

```text
bible/chapters/bundles/
├── kjv.json.gz
└── kjvs.json.gz
```

These files are Resource content.

They are **not** ResourceDescriptor documents.

The Resource Publishing CLI uploads the bundle bytes and generates the corresponding ResourceDescriptor during publication.

Conceptually:

```text
bundle
    ↓
Blossom
    ↓
ResourceDescriptor
    ↓
Nostr Resource event
```

---

# Bible Chapter Bundles

Bible chapter bundles contain multiple Chapter Resources keyed by version and chapter location.

Example:

```json
{
  "kjvs/1_1": {},
  "kjvs/1_2": {}
}
```

The bundle Resource provides an efficient way to install an entire Bible version while the individual `content/` Resources allow chapter-level publication and resolution.

---

# Bible Overlays

Bible-specific overlays live under the Bible domain:

```text
bible/overlays/
```

Current overlays include:

```text
paragraphs/
pericopes/
```

Keeping overlays inside their owning domain allows other domains to define their own overlays later without introducing a global overlay namespace.

---

# Bible Indexes

Search indexes live under:

```text
bible/indexes/
```

For example:

```text
bible/indexes/bible/bundles/kjv.json.gz
```

Indexes are generated serialized Resources consumed by the application rather than source documents intended for manual editing.

---

# Bible Metadata

Bible metadata lives under:

```text
bible/metadata/
```

Current metadata includes:

```text
booknames/
```

For example:

```text
bible/metadata/booknames/bundles/default.json.gz
```

---

# Strong's Definitions

Strong's definition Resources live under:

```text
strongs/definitions/
```

Current bundled data is stored under:

```text
strongs/definitions/bundles/
```

For example:

```text
strongs/definitions/bundles/kjvs.json.gz
```

---

# Git LFS

Large generated data files are stored using Git LFS.

The repository tracks compressed JSON files using:

```text
*.json.gz
```

You must have Git LFS installed before cloning or working with the repository.

## Install Git LFS

macOS:

```bash
brew install git-lfs
```

Initialize it for your user:

```bash
git lfs install
```

---

# Clone the Repository

Clone normally:

```bash
git clone <repository-url>
cd kjvonly-data
```

Git LFS should download tracked files automatically.

If necessary:

```bash
git lfs pull
```

Verify tracked files:

```bash
git lfs ls-files
```

---

# Verify a File Was Downloaded

A checked-out LFS file should contain the actual Resource bytes rather than the small Git LFS pointer document.

For example:

```bash
gzip -t bible/chapters/bundles/kjv.json.gz
```

A successful command with no output indicates that the gzip file is valid.

---

# Data Integrity

For migrations, repository rebuilds, or fresh-clone verification, the complete repository data can be checked with SHA-256 hashes.

Generate a checksum list:

```bash
find bible strongs -type f -print0 \
  | xargs -0 shasum -a 256 \
  | sort \
  > data.sha256
```

The resulting file contains both the SHA-256 digest and filename:

```text
<sha256>  bible/chapters/bundles/kjv.json.gz
<sha256>  bible/chapters/bundles/kjvs.json.gz
...
```

After cloning or migrating the repository, generate another list:

```bash
find bible strongs -type f -print0 \
  | xargs -0 shasum -a 256 \
  | sort \
  > data-clone.sha256
```

Compare them:

```bash
diff -u data.sha256 data-clone.sha256
```

No output means the filenames and file contents match exactly.

If additional top-level data domains are added later, include them in the checksum command as well.

---

# Publication

This repository is intended to be consumed by the **KJVOnly Resource Publishing CLI**.

Publication manifests define how files in this repository become Published Resources.

The manifest is responsible for mapping:

```text
filesystem path
    ↓
Resource identity
    ↓
Resource representation
    ↓
publication strategy
```

For example, a file such as:

```text
bible/chapters/bundles/kjvs.json.gz
```

may be published as:

```text
kjvonly/bible/chapters/kjvs
```

The filesystem hierarchy and Published Resource namespace do not need to be identical.

The publication manifest is the explicit bridge between them.

---

# Generated Data

Most files in this repository are generated artifacts.

When changing the data pipeline:

1. regenerate the relevant Resources,
2. verify the resulting files,
3. regenerate affected bundles or indexes,
4. review the changed files,
5. commit the updated LFS objects.

Avoid manually modifying generated `.json.gz` files unless specifically debugging the generation process.

---

# Adding New Data

New data should follow the domain-first hierarchy:

```text
<domain>/
└── <resource-category>/
```

Use:

```text
content/
```

for individual Resources intended for direct Nostr publication.

Use:

```text
bundles/
```

for serialized Resources intended for external object publication.

For example:

```text
plans/
└── <resource-category>/
    ├── content/
    └── bundles/
```

Do not create empty `content/` or `bundles/` directories purely for symmetry.

Create them when the Resource category actually uses that publication form.

---

# Design Principle

This repository represents application data, not transport infrastructure.

The important separation is:

```text
KJVOnly Data
    =
serialized Resource content

Publication Manifest
    =
publication contract

Resource Publishing CLI
    =
publication implementation

Nostr / Blossom
    =
transport and remote storage

KJVOnly Application
    =
Resource consumer
```

Keeping those responsibilities separate allows the data layout to remain domain-oriented while publication strategies can evolve independently.
