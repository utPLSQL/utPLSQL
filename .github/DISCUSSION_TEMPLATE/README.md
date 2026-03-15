# GitHub Discussions — setup guide for utPLSQL/utPLSQL

This folder contains the discussion category form templates that power structured
GitHub Discussions for the utPLSQL project.

---

## File → category mapping

<aside>
The filename slug **must exactly match** the slug GitHub generates for your category name.
GitHub derives the slug by lowercasing the category name and replacing spaces and special
characters with hyphens.
</aside>

| File                   | Category name to create in GitHub | Format                | Who can post                   |
|------------------------|-----------------------------------|-----------------------|--------------------------------|
| `announcements.yml`    | 📢 Announcements                  | Announcement          | Maintainers only               |
| `rfcs-design.yml`      | 💡 RFCs & Design                  | Open-ended discussion | Everyone                       |
| `architecture.yml`     | 🏗 Architecture                   | Open-ended discussion | Everyone                       |
| `release-planning.yml` | 🗓 Release Planning               | Open-ended discussion | Maintainers only (recommended) |
| `q-a.yml`              | ❓ Q&A                             | Question / Answer     | Everyone                       |
| `show-and-tell.yml`    | 🔬 Show & Tell                    | Open-ended discussion | Everyone                       |
| `contributors.yml`     | 🤝 Contributors                   | Open-ended discussion | Everyone                       |
| `general.yml`          | 💬 General                        | Open-ended discussion | Everyone                       |

> **Polls** are a built-in GitHub Discussions type and do not support YAML templates.
> Create a 🗳 Polls category manually (type: Poll) — no template file needed.

---

## Step-by-step setup

### 1. Enable Discussions
Go to **Settings → Features** and check **Discussions**.

### 2. Create the categories
Go to **Discussions → Categories → ✏️ Edit categories** (gear icon).

Create each category listed in the table above.  
**Order matters** — drag to set the display order shown below:

1. 📢 Announcements
2. 💡 RFCs & Design
3. 🏗 Architecture
4. 🗓 Release Planning
5. ❓ Q&A
6. 🔬 Show & Tell
7. 🤝 Contributors
8. 🗳 Polls
9. 💬 General

### 3. Commit the templates
Copy all `.yml` files from this folder into `.github/DISCUSSION_TEMPLATE/` in
the **default branch** (usually `develop` for utPLSQL).

```
.github/
└── DISCUSSION_TEMPLATE/
    ├── announcements.yml
    ├── rfcs-design.yml
    ├── architecture.yml
    ├── release-planning.yml
    ├── q-a.yml
    ├── show-and-tell.yml
    ├── contributors.yml
    └── general.yml
```

### 4. Configure category permissions

| Category         | Setting                                          |
|------------------|--------------------------------------------------|
| Announcements    | Set to **Maintainers only** in category settings |
| Release Planning | Recommended: **Maintainers only**                |
| All others       | Open to all                                      |

### 5. Create the welcome pinned post

Create a first discussion in **Announcements** titled  
**"Welcome to utPLSQL Discussions — how to use this space"**

Suggested body:

```markdown
## Welcome 👋

This is the place for design discussions, feature proposals, and community
conversation around utPLSQL.

### Where to post

| I want to… | Use |
|---|---|
| Propose a new feature or behaviour change | 💡 RFCs & Design |
| Discuss internal architecture | 🏗 Architecture |
| Ask a usage / how-to question | ❓ Q&A |
| Share a CI pipeline, integration, or tip | 🔬 Show & Tell |
| Ask about contributing / development setup | 🤝 Contributors |
| Vote on priorities | 🗳 Polls |
| Anything else | 💬 General |

### Discussions vs Issues

**Discussions** are for ideas that are still open, need input, or require consensus.  
**Issues** are for well-scoped work that someone can pick up and implement.

A maintainer will convert a Discussion to an Issue once scope is agreed.

### Real-time chat

For quick questions: [utPLSQL Slack](https://utplsql.slack.com)  
For decisions that need a permanent record: post here.
```

Pin this post from the discussion's `…` menu → **Pin discussion**.

### 6. Update the README

Add a Discussions badge to the project README:

```markdown
[![GitHub Discussions](https://img.shields.io/github/discussions/utPLSQL/utPLSQL)](https://github.com/utPLSQL/utPLSQL/discussions)
```

And add a short paragraph in the "Community" or "Contributing" section pointing
to Discussions as the place for design proposals.

---

## Operating guidelines

### Discussion → Issue conversion rule

| Category      | Convert when…                                                        |
|---------------|----------------------------------------------------------------------|
| RFCs & Design | Consensus reached, scope is defined                                  |
| Architecture  | Breaking change formally agreed by maintainers                       |
| Q&A           | A confirmed bug surfaces in the thread                               |
| Contributors  | A gap in docs or tooling is identified that can be filed as an issue |

Use the **"Create issue from discussion"** button (available in the discussion's sidebar).

### Housekeeping

- Lock **Announcements** threads after 30 days.
- Close **Polls** after 14 days; post a summary comment with the result before closing.
- Label cross-references: apply the same labels used on issues
  (`enhancement`, `breaking-change`, `coverage`, `oracle-version`, etc.)
  to discussions for consistent search.
