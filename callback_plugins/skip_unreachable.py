# Stdout callback: the stock output, minus the hosts that were simply not there.
#
# Roughly half the workstation inventory is powered off at any given time, and
# the default callback reports each one as a red "fatal: UNREACHABLE!" block
# mid-run and again as a line in PLAY RECAP. That buries the hosts that did
# something in the hosts that could not be reached, which is the opposite of
# what a recap is for.
from __future__ import annotations

DOCUMENTATION = """
    name: skip_unreachable
    type: stdout
    short_description: default output, with never-reached hosts kept out of the recap
    description:
        - Identical to the C(default) callback, except that a host which was
          unreachable and did nothing else is condensed to a single skip line
          during the run and omitted from PLAY RECAP entirely.
        - A host that ran real work and then went unreachable -- a reboot that
          does not come back, for instance -- is left alone, because that is a
          failure worth seeing.
    extends_documentation_fragment:
      - default_callback
      - result_format_callback
    options:
      show_skipped_count:
        description:
          - Print a one-line count of the hosts left out of PLAY RECAP.
          - Without it a machine can stay down for months with nothing in the
            output to say so.
        type: bool
        default: true
        ini:
          - section: callback_skip_unreachable
            key: show_skipped_count
        env:
          - name: ANSIBLE_SKIP_UNREACHABLE_SHOW_COUNT
    requirements:
      - set as stdout in configuration
"""

from ansible import constants as C
from ansible.plugins.callback.default import CallbackModule as DefaultCallback


class CallbackModule(DefaultCallback):

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'skip_unreachable'

    @staticmethod
    def _did_work(summary):
        """True if the host got far enough that its absence is worth reporting.

        Deliberately not `ok == 0`: with `gathering = smart` and a warm fact
        cache a second run skips gather_facts, and `skipped` accrues from any
        `when:` the controller evaluates without connecting. Only changed,
        failures and rescued mean the host actually answered.
        """
        return bool(summary['changed'] or summary['failures'] or summary['rescued'])

    def v2_runner_on_unreachable(self, result):
        # Keep the task banner: under `strategy: free` a bare skip line gives no
        # clue which task the host dropped out on.
        if self._last_task_banner != result.task._uuid:
            self._print_task_banner(result.task)

        self._handle_warnings(result.result)

        # Warnings stay, but the structured error block does not: it is a dozen
        # red lines of playbook source for a machine that is merely switched
        # off, and the reason survives in the one-line message below. Ask for it
        # with -v when a host is unreachable for a reason worth reading.
        if self._display.verbosity > 0:
            self._handle_exception(result.result, use_stderr=self.get_option('display_failed_stderr'))
        else:
            result.result.pop('exception', None)

        # One line instead of the JSON dump, but keep the reason -- a refused
        # key and a powered-off machine read the same otherwise.
        msg = ' '.join(str(result.result.get('msg') or 'unreachable').split())
        msg = msg.removeprefix('Task failed: ')
        self._display.display(
            "skipping: [%s] => unreachable (%s)" % (self.host_label(result), msg),
            color=C.COLOR_SKIP,
        )

    def v2_playbook_on_stats(self, stats):
        hidden = {}
        for host in list(stats.processed):
            summary = stats.summarize(host)
            if summary['unreachable'] and not self._did_work(summary):
                hidden[host] = stats.processed.pop(host)

        # Other aggregate callbacks are handed this same stats object after us,
        # so the hosts go back whatever happens above.
        try:
            super().v2_playbook_on_stats(stats)
        finally:
            stats.processed.update(hidden)

        if hidden and self.get_option('show_skipped_count'):
            self._display.display(
                "skipped %d unreachable host(s)" % len(hidden),
                color=C.COLOR_SKIP,
            )
