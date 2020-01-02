---
title: Contribute Code
created_at: 2018/09/17
excerpt: Workarea is an open-source commerce platform, so anyone can contribute to it! In this guide, you'll how to make your own contributions to Workarea using GitHub and Pull Requests.
---

# Contribute Code

Workarea is an open-source commerce platform, so anyone can contribute to it! In this guide, you'll learn how to make your own contributions to Workarea using GitHub and Pull Requests. First off, if you don't already have a GitHub account, create one. With a GitHub account and a fork of the Workarea repo, you'll be able to contribute both code and [documentation](/articles/contribute-documentation.html) to the platform.

## Contributing Security Fixes

Any security changes should follow the [security policy](/articles/security-policy.html), which describes a process by which you can report vulnerabilities to the Workarea core team.

## Patching the Platform

Workarea will only accept patches to the platform that contain the minimum viable amount of code change to solve the problem you're having. For example, rewriting an entire class to suit a particular code style is not something that will be accepted in a patch version of the platform. The reason for this is that Workarea developers typically inspect the diff of each version that they upgrade their projects to, in order to spot any changes made in the platform that could affect their decorated code. It's much more difficult to understand what needed to be changed if there are a lot of unnecessary changes in the same file. Before making your pull request, make sure you're not doing any unnecessary refactors or rewrites of the code.

## Pull Requests

All changes to Workarea are made in the form of a pull request. Pull requests to the platform should be thought of not as an "approval process", but rather as a means of discussing a particular change. The only difference between a GitHub issue and a pull request is that the pull request contains code.

Pull requests must be made to their **lowest common denominator** version. If you're making changes for the next Workarea v3.0.x patch, you'll need to branch from (and pull request back to) the `v3.0-stable` branch. These branches are "merged up" all the way to `master` when we build for QA or on patch release day, so your changes will be applied to all subsequent patch versions that have a higher minor. Doing things this way prevents developers from having to make the same pull request against multiple branches of the platform, which can diffuse the discussion.

Before making the pull request, make sure your topic branch is up-to-date with its parent branch by rebasing against it. Be sure to `git pull` the parent branch _before_ rebasing so you know you're getting the absolute latest and greatest. Squash your commits and rebase against the branch that you will merge into so that your topic branch is exactly one commit ahead of the long running branch. This allows your changes to be easily cherry-picked for additional pull requests and keeps the commit log clean. Don't worry too much if this confuses you, GitHub allows the platform team to squash your commits into one if we need to.

### Commit Messages

Write your commit message as if it will be used as an entry in the changelog. Consider your audience: systems integrators upgrading to a new version of Workarea.

Follow [the seven rules of a great git commit message](http://chris.beams.io/posts/git-commit/#seven-rules). Use [Markdown](http://daringfireball.net/projects/markdown/) for text formatting, such as marking up a list or delimiting code (see example/template below).

Include the GitHub issue number (if any) on the last line(s) of the commit message.

**Note:** In the event your commit is not relevant to readers of the changelog, include the string "No changelog" within the commit message.

#### Commit Message Example/Template

```
Summarize changes in around 50 characters or less

More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. In some contexts, the first line is treated as the
subject of the commit and the rest of the text as the body. The
blank line separating the summary from the body is critical (unless
you omit the body entirely); various tools like `log`, `shortlog`
and `rebase` can get confused if you run the two together.

Explain the problem that this commit is solving. Focus on why you
are making this change as opposed to how (the code explains that).
Are there side effects or other unintuitive consequenses of this
change? Here's the place to explain them.

Further paragraphs come after blank lines.

* Bullet points are okay, too.

* Use an asterisk for the bullet.

* Keep bullets flush left. Line breaks between bullets are optional.

Put the GitHub issue number on the last line, like this:

Closes #8
```

### Code Review

The next step is to actually make the pull request. When you push your branch to your fork on GitHub, a yellow window will appear above the code browser prompting you to create a new pull request. Click this button, and the contents of your commit (if you squashed!) will be automatically used as the initial message in the pull request. This is also using [Markdown](http://daringfireball.net/projects/markdown/), so you can mark up your PR message in any way you choose. Once the pull request is made, reviewers will be automatically added according to the `REVIEWERS` file at the root of the repo. If you wish to add any other reviewers, you can do so at this time. One (or more) of these developers will review your code and either choose to merge the request, **request changes** from you, or actually make a **suggestion** as a code diff in the PR comments. Code review can sometimes be a lengthy process, so be prepared to discuss your changes with platform developers, contributors to the platform, and just about anyone who's interested on the web.
