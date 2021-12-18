def toint(c):
    if c.isdigit():
        return int(c)
    return 10 + ord(c) - 97


def tochr(j):
    if j <= 9:
        return str(j)
    return chr(97 + j - 10)


def isnumber(c):
    return c not in ["[", "]", ","]


def isnumbergt9(c):
    return isnumber(c) and not c.isdigit()


def seeknum(s, i, length):
    while i < length:
        c = s[i]
        if isnumber(c):
            return (toint(c), i)
        i += 1
    return 0, -1


def findexpl(s):
    length = len(s)
    leftnum = 0
    i_leftnum = -1
    count = 1
    i = 1
    while i < length - 4:
        c = s[i]
        if c == "[":
            count += 1
        elif c == "]":
            count -= 1
        elif c != ",":
            if count > 4 and s[i + 1] == "," and isnumber(s[i + 2]):
                pair_right = toint(s[i + 2])
                rightnum, i_rightnum = seeknum(s, i + 3, length)
                return (
                    (leftnum, i_leftnum),
                    (toint(c), i),
                    (pair_right, i + 2),
                    (rightnum, i_rightnum),
                )
            else:
                leftnum = toint(c)
                i_leftnum = i
        i += 1
    return None


def add(i, v):
    j = i + v
    return tochr(j)


def explode(s, ler):
    (
        (leftnum, i_leftnum),
        (pair_left, i_pair_left),
        (pair_right, i_pair_right),
        (rightnum, i_rightnum),
    ) = ler
    s = list(s)
    if i_leftnum >= 0:
        s[i_leftnum] = add(leftnum, pair_left)
    if i_rightnum >= 0:
        s[i_rightnum] = add(rightnum, pair_right)
    s = s[0 : i_pair_left - 1] + ["0"] + s[i_pair_right + 2 :]
    return "".join(s)


def split(s, i_gt9):
    c = s[i_gt9 : i_gt9 + 1]
    v = 10 + ord(c) - 97
    l = v // 2
    r = tochr(v - l)
    l = tochr(l)
    spair = f"[{l},{r}]"
    s = s.replace(c, spair, 1)
    return s


def reduce(s):
    running = True
    while running:
        ler = findexpl(s)
        i_gt9 = -1
        if ler is not None:
            s = explode(s, ler)
        else:
            try:
                i_gt9 = next(i for (i, c) in enumerate(list(s)) if isnumbergt9(c))
                s = split(s, i_gt9)
            except StopIteration:
                pass
        running = (ler is not None) or i_gt9 != -1
    return s


def magnitude(v):
    if isinstance(v, list):
        [l, r] = v
        return 3 * magnitude(l) + 2 * magnitude(r)
    else:
        return v


def add_reduce(s1, s2):
    s = f"[{s1},{s2}]"
    s = reduce(s)
    return s


def addlist(raw):
    lines = [ln.strip() for ln in raw.split("\n") if ln.strip() != ""]
    s = lines[0]
    i = 1
    N = len(lines)
    while i < N:
        s2 = lines[i]
        s = add_reduce(s, s2)
        i += 1
    lst = eval(s)
    m = magnitude(lst)
    return s, m


def largest_magnitude(raw):
    lines = [ln.strip() for ln in raw.split("\n") if ln.strip() != ""]
    N = len(lines)
    greatest = 0
    for i in range(N):
        for j in range(N):
            if j == i:
                continue
            s = add_reduce(lines[i], lines[j])
            m = magnitude(eval(s))
            if m > greatest:
                greatest = m
    return greatest


with open("input.txt", "r") as f:
    raw = f.read()

_, m = addlist(raw)
print(m)

print(largest_magnitude(raw))
