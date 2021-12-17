from enum import Enum
import re


def parseraw(raw):
    captures = re.findall(r"(-?\d+)\.\.(-?\d+)", raw)
    [(x1, x2), (y2, y1)] = captures
    [x1, x2, y1, y2] = [int(a) for a in [x1, x2, y1, y2]]
    return ((x1, x2), (y1, y2))


class ProbeStatus(Enum):
    GOING = 1
    HIT = 2
    MISS = 3


def check_status(probe, target):
    probe_x, probe_y = probe
    ((t_x1, t_x2), (t_y1, t_y2)) = target

    if probe_x >= t_x1 and probe_x <= t_x2 and probe_y <= t_y1 and probe_y >= t_y2:
        return ProbeStatus.HIT

    if probe_y <= t_y2:
        return ProbeStatus.MISS

    return ProbeStatus.GOING


def step(probe, velocity, target):
    probe_x, probe_y = probe
    v_x, v_y = velocity

    probe_x += v_x
    probe_y += v_y

    if v_x > 0:
        v_x -= 1
    v_y -= 1

    probe = (probe_x, probe_y)
    velocity = (v_x, v_y)
    status = check_status(probe, target)

    return probe, velocity, status


def test(probe, velocity, target):
    max_y = -1_000_000
    status = ProbeStatus.GOING
    while status == ProbeStatus.GOING:
        _, probe_y = probe
        if probe_y > max_y:
            max_y = probe_y
        probe, velocity, status = step(probe, velocity, target)
    return status, max_y


def brute(target, brute_range):
    probe = (0, 0)
    ((b_x1, b_x2), (b_y1, b_y2)) = brute_range
    max_max_y, best_v = -1_000_000, (0, 0)
    count_hits = 0
    for y in range(b_y1, b_y2 - 1, -1):
        print(f"y={y}")
        for x in range(b_x1, b_x2 + 1):
            velocity = (x, y)
            status, max_y = test(probe, velocity, target)
            if status == ProbeStatus.HIT:
                count_hits += 1
                if max_y > max_max_y:
                    max_max_y = max_y
                    best_v = velocity
    return max_max_y, best_v, count_hits


with open("input.txt", "r") as f:
    target = parseraw(f.read())

brute_range = ((1, 1000), (1000, -126))

max_max_y, best_v, count_hits = brute(target, brute_range)
print(f"best velocity: {best_v}\nmax height: {max_max_y}\nhit count: {count_hits}")
