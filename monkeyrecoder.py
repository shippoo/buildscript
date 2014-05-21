#!/usr/bin/env python
# coding=utf-8

from com.android.monkeyrunner import MonkeyRunner,MonkeyDevice
from com.android.monkeyrunner.recorder import MonkeyRecorder

device = MonkeyRunner.waitForConnection()
MonkeyRecorder.start(device)

