"""Unit tests for the critic trigger logic.  Run: python3 -m unittest discover -s .github/critic"""

import os
import random
import unittest
from unittest import mock

import critic


def cfg(**kw):
    base = dict(threshold=300, probability=0.25, label="critic", models=["argon", "opus"],
                max_diff_chars=1000, ignore=["*.lock"])
    base.update(kw)
    return critic.Config(**base)


def event(action="opened", additions=10, deletions=0, labels=(), draft=False, label=None):
    ev = {"action": action, "pull_request": {
        "number": 1, "additions": additions, "deletions": deletions, "draft": draft,
        "labels": [{"name": n} for n in labels]}}
    if label:
        ev["label"] = {"name": label}
    return ev


class FixedRng(random.Random):
    def __init__(self, value):
        super().__init__(0)
        self.value = value

    def random(self):
        return self.value


class DecideTests(unittest.TestCase):
    def test_over_threshold_always_runs(self):
        run, reason = critic.decide(event(additions=200, deletions=100), cfg(), FixedRng(0.99))
        self.assertTrue(run)
        self.assertIn("300 lines", reason)

    def test_under_threshold_runs_on_lucky_roll(self):
        self.assertTrue(critic.decide(event(), cfg(), FixedRng(0.10))[0])

    def test_under_threshold_skips_on_unlucky_roll(self):
        self.assertFalse(critic.decide(event(), cfg(), FixedRng(0.25))[0])

    def test_label_forces_run(self):
        self.assertTrue(critic.decide(event(labels=["critic"]), cfg(), FixedRng(0.99))[0])

    def test_critic_label_added(self):
        self.assertTrue(critic.decide(event("labeled", label="critic"), cfg(), FixedRng(0.99))[0])

    def test_unrelated_label_never_runs(self):
        self.assertFalse(critic.decide(event("labeled", label="bug", additions=5000), cfg(), FixedRng(0.0))[0])

    def test_draft_skipped_unless_labelled(self):
        self.assertFalse(critic.decide(event(draft=True, additions=5000), cfg(), FixedRng(0.0))[0])
        self.assertTrue(critic.decide(event(draft=True, labels=["critic"]), cfg(), FixedRng(0.99))[0])

    def test_probability_zero_and_one(self):
        self.assertFalse(critic.decide(event(), cfg(probability=0.0), FixedRng(0.0))[0])
        self.assertTrue(critic.decide(event(), cfg(probability=1.0), FixedRng(0.999))[0])


class PickModelTests(unittest.TestCase):
    def test_only_models_with_keys(self):
        with mock.patch.dict(os.environ, {"ANTHROPIC_API_KEY": "x"}, clear=True):
            self.assertEqual([m.key for m in critic.pick_models(cfg(), random.Random(1))], ["opus"])

    def test_both_models_get_picked_first_sometimes(self):
        with mock.patch.dict(os.environ, {"ANTHROPIC_API_KEY": "x", "GEMINI_API_KEY": "y"}, clear=True):
            firsts = {critic.pick_models(cfg(), random.Random(s))[0].key for s in range(50)}
        self.assertEqual(firsts, {"argon", "opus"})


class DiffTests(unittest.TestCase):
    def test_ignore_and_budget(self):
        files = [
            {"filename": "yarn.lock", "status": "modified", "additions": 1, "deletions": 1, "patch": "@@"},
            {"filename": "a.py", "status": "added", "additions": 1, "deletions": 0, "patch": "+x"},
            {"filename": "big.py", "status": "added", "additions": 1, "deletions": 0, "patch": "+" * 5000},
            {"filename": "img.png", "status": "added", "additions": 0, "deletions": 0},
        ]
        diff, skipped = critic.build_diff(files, cfg())
        self.assertIn("+++ a.py", diff)
        self.assertIn("patch not available", diff)
        self.assertEqual(skipped, ["yarn.lock (ignored)", "big.py (over size budget)"])


class ConfigTests(unittest.TestCase):
    def test_empty_vars_fall_back_to_defaults(self):
        env = {"CRITIC_LINE_THRESHOLD": "", "CRITIC_PROBABILITY": "", "CRITIC_MODELS": ""}
        with mock.patch.dict(os.environ, env, clear=True):
            c = critic.Config.from_env()
        self.assertEqual((c.threshold, c.probability, c.models), (300, 0.25, ["argon", "opus"]))

    def test_unknown_model_rejected(self):
        with mock.patch.dict(os.environ, {"CRITIC_MODELS": "gpt"}, clear=True):
            with self.assertRaises(SystemExit):
                critic.Config.from_env()


if __name__ == "__main__":
    unittest.main()
