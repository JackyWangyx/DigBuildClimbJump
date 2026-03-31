local EaseInOutElastic = {}

function EaseInOutElastic:Ease(from, to, delta)
    local d = 1
    local p = d * 0.3
    local a = 0
    local s = 0

    to = to - from

    if math.abs(delta) < 1e-6 then
        return from
    end

    delta = delta / (d / 2)
    if math.abs(delta - 2) < 1e-6 then
        return from + to
    end

    if math.abs(a) < 1e-6 or a < math.abs(to) then
        a = to
        s = p / 4
    else
        s = p / (2 * math.pi) * math.asin(to / a)
    end

    if delta < 1 then
        delta = delta - 1
        return -0.5 * (a * 2^(10 * delta) * math.sin((delta * d - s) * (2 * math.pi) / p)) + from
    else
        delta = delta - 1
        return a * 2^(-10 * delta) * math.sin((delta * d - s) * (2 * math.pi) / p) * 0.5 + to + from
    end
end

return EaseInOutElastic
