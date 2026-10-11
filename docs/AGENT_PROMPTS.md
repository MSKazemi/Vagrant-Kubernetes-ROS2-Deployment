# Reusable coding-agent prompts for first contributions

These are **copy-and-paste prompts** for Claude Code and OpenAI Codex. Start either tool in your checkout and make a branch before using them; the [beginner walkthrough](./AI_ASSISTED_CONTRIBUTING.md) explains how. **Read the live issue first**, because its status and requirements may have changed.

Agents must follow [AGENTS.md](../AGENTS.md) and [CONTRIBUTING.md](../CONTRIBUTING.md). If they cannot access the GitHub issue, paste the current description. They should not invent issue requirements, skip review, or claim tests were run without evidence.

## 1. First documentation PR: issue #25 — screenshot links

```text
I am contributing to issue #25:
https://github.com/MSKazemi/Vagrant-Kubernetes-ROS2-Deployment/issues/25

First read AGENTS.md and the current issue body, asking me to paste it if you lack GitHub access.
Inspect MonitoringSystem/README.md and the committed images/ directory.
Find broken local image paths; check whether images/k8s1.png actually exists.
If a referenced file is missing and no matching screenshot exists, remove that image
reference while keeping the explanation readable. Don't invent screenshot files.
Make meaningful, concise alt text for the remaining images based on their actual content.
Edit only the necessary Markdown. Check the affected local image links and show your findings.
Do not run Vagrant or modify Kubernetes manifests. At the end, show the diff,
validation you performed, and what you did not verify.
```

**Human check:** Compare every image path with `images/` and visually inspect any screenshot whose description changed. Do not accidentally publish secrets shown in screenshots.

## 2. Documentation + accuracy: issue #24 — ROS 2 workload guide

```text
Help me complete the currently open issue #24. Read AGENTS.md, ROS2/README.md,
README.md and the three existing ROS2/ros_dep_*.yaml manifests first.
Check the issue body before making changes.
Identify the nonexistent ros_dep.yaml reference, namespace omissions and
the fact that these manifests start stress-ng rather than talker/listener.
Propose a documentation-only correction. Avoid claiming successful DDS messages
or upgrading the stack; the actual runtime fix is tracked in issue #14.
After approval, make only the minimal docs edits, check local references
against committed files, and summarize remaining runtime limitations.
Do not start Vagrant or change cluster security settings.
```

**Human check:** The commands should refer to real files, namespaces and workload behavior. Do not mark the issue as fixed if acceptance criteria are unmet.

## 3. First coding PR: issue #28 — Bash CI syntax check

```text
I want to implement open issue #28 with a small PR.
Read AGENTS.md, the issue text, and .github/workflows/main.yaml.
First propose a minimal separate GitHub Actions workflow that runs Bash syntax
checks on tracked *.sh files for PRs. It must not need Docker Hub secrets,
push container images, start Vagrant VMs, or rewrite all the existing scripts.
Use a robust list of files including paths with spaces.
Explain how you will prove a deliberately invalid script causes a nonzero exit,
without committing the invalid file. Do not change runtime behavior or publish artifacts.
After I approve, implement the workflow, document the local verification command
in CONTRIBUTING.md, and show checks actually run and ones still awaiting GitHub CI.
```

**Human check:** Review workflow permissions/triggers; ensure a green static job does not imply the cluster was tested.

## 4. Kubernetes validation: issue #29 — manifest schemas

```text
I want to work on issue #29. Read AGENTS.md and the open issue first.
Inspect ROS2/*.yaml and identify built-in Kubernetes resources versus
the VerticalPodAutoscaler custom resource. Propose a maintained offline
schema-checking workflow with pinned tool version.
Do not silently claim a built-in schema covers VerticalPodAutoscaler;
either validate using an appropriate pinned CRD schema or explicitly document
the excluded file. Keep PR checks independent of a cluster or credentials.
After approval, implement minimal CI/doc changes and report actual validation.
```

**Human check:** Any VPA schema exception must be deliberate and documented, not a fake green test.

## 5. Advanced issue #14 — ROS 2 talker/listener integration

```text
I want to plan (not immediately implement) issue #14.
Read AGENTS.md, the issue, ROS2/Dockerfile, the workload YAML files,
Network/network_plugin.sh and the relevant documentation.
Explain the dependencies on #7 (supported ROS image) and #15 (DDS discovery),
the difference between ROS 2 nodes and Kubernetes workers, and
how to validate cross-worker communication with explicit node placement.
Propose a phased approach and an executable smoke-test specification with
timeouts, expected observable subscriber output, and failure diagnostics.
Do not claim automatic multi-node DDS works or change production/safety settings.
Wait for human approval before editing.
```

**Human check:** A listener receiving a message is not cross-worker evidence unless node placement and middleware configuration are also verified.

## 6. Skeptical pre-PR review (any issue)

```text
Review my uncommitted changes against AGENTS.md and the selected GitHub issue.
Inspect git diff and relevant tests. List concrete correctness, security,
documentation and scope problems with file paths and severity.
Distinguish tests you observed from ones you did not run.
Do not edit, commit, push, publish artifacts, or merge a PR.
End with a short verification checklist I can execute myself.
```

Use this final prompt even if another agent wrote the patch. When in doubt, ask a maintainer before expanding the scope.
