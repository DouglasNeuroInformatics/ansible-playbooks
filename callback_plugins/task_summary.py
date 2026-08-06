from __future__ import annotations

from ansible.plugins.callback import CallbackBase


class CallbackModule(CallbackBase):
    """Print a per-task failure summary at the end of a run."""

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = "aggregate"
    CALLBACK_NAME = "task_summary"
    CALLBACK_NEEDS_ENABLED = True

    def __init__(self):
        super().__init__()
        self._ok = 0
        self._changed = 0
        self._failed = []
        self._ignored = []
        self._unreachable = []

    def _label(self, result):
        return f"  - {result._task.get_name()} (on {result._host.get_name()})"

    def v2_runner_on_ok(self, result):
        self._ok += 1
        if result._result.get("changed"):
            self._changed += 1

    def v2_runner_on_failed(self, result, ignore_errors=False):
        if ignore_errors:
            self._ignored.append(self._label(result))
        else:
            self._failed.append(self._label(result))

    def v2_runner_on_unreachable(self, result):
        self._unreachable.append(self._label(result))

    def v2_playbook_on_stats(self, stats):
        out = [
            "\n===== TASK SUMMARY =====",
            f"Successful: {self._ok} (changed: {self._changed})",
            f"Ignored: {len(self._ignored)}",
            f"Failed ({len(self._failed)}):",
            *(self._failed or ["  (none)"]),
            f"Unreachable ({len(self._unreachable)}):",
            *(self._unreachable or ["  (none)"]),
        ]
        self._display.display("\n".join(out))
