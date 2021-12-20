import itertools


def parseraw(raw):
    lines = [ln.strip() for ln in raw.split("\n") if ln.strip() != ""]
    alg = lines[0]
    srcimg = lines[1:]
    w = len(srcimg[0])
    h = len(srcimg)
    points = []
    y = 0
    for ln in srcimg:
        x = 0
        for c in ln:
            if c == "#":
                points.append((x, y))
            x += 1
        y += 1
    alg_bin = [(1 if c == "#" else 0) for c in alg]
    return alg_bin, (w, h, points)


def cycle(points, alg, void=0):
    min_x = min(x for (x, _) in points)
    max_x = max(x for (x, _) in points)
    min_y = min(y for (_, y) in points)
    max_y = max(y for (_, y) in points)

    output = []
    for y, x in itertools.product(range(min_y - 1, max_y + 2), range(min_x - 1, max_x + 2)):

        # idx = get3x3v(points, x, y, min_x, max_x, min_y, max_y, void)
        idx = 0
        mask = 0b100_000_000
        lshift = 8
        v = y - 1
        j = 0
        while j < 3:
            u = x - 1
            i = 0
            while i < 3:
                if u < min_x or u > max_x or v < min_y or v > max_y:
                    b = void
                else:
                    b = 1 if (u, v) in points else 0
                idx |= (b << lshift) & mask
                mask >>= 1
                lshift -= 1
                u += 1
                i += 1
            v += 1
            j += 1

        out = alg[idx]
        if out:
            output.append((x - min_x + 1, y - min_y + 1))
    return output


def cycles_alternating_void(points, alg, num_cycles):
    from sys import stdout

    void = 0
    points_ = list(points)
    for n in range(num_cycles):
        points_ = cycle(points_, alg, void=void)
        print(f"\rPass {n+1:2}/{num_cycles:2}: {len(points_):4}", end="")
        stdout.flush()
        void ^= 1
    print()
    return len(points_), points_


with open("input.txt", "r") as f:
    raw = f.read()

alg, (w, h, points) = parseraw(raw)
num_points, points = cycles_alternating_void(points, alg, 2)
print(num_points)
num_points, points = cycles_alternating_void(points, alg, 48)
print(num_points)
