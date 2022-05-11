function lab04
    clc;
    debug = true;

    a = 0;
    b = 1;
    eps = 1e-6;
    dx = 1e-6;

    fplot(@(x) func(x), [a, b], 'b');
    hold on;

    global N;
    N = 0;

    manual = true;
    methods = ["Метод ньютона", "fminbnd"];
    if (manual)
        [x, f] = newton(a, b, eps, dx, debug);
    else
        [x, f] = fminbnd(@func, a, b, optimset('Display', 'iter', 'TolX', eps));
    end
    fprintf('Минимум функции: (x=%12.10f, f=%12.10f)\n', x, f);
    fprintf('N = %d\n', N);
    p = plot(x, f, 'rx', 'MarkerSize', 15);
    legend(p, methods(1 + ~manual), 'Location', 'northwest');

    hold off;
end

function y = func(x)
    global N;
    N = N + 1;

    x3 = power(x, 3);
    x2 = power(x, 2);
    sqrt2 = sqrt(2);

    ch = cosh((3 * x3 + 2 * x2 - 4 * x + 5) / 3);
    th = tanh((x3 - 3 * sqrt2 * x - 2) / (2 * x + sqrt2));

    y = ch + th - 2.5;
end

function [x, f] = newton(a, b, eps, dx, debug)
    [xl, xr] = goldenSectionBoundaries(a, b);
    x = (xl + xr) / 2;

    run = true;
    iteration = 1;
    while (run)
        f_plus = func(x + dx);
        f = func(x);
        f_minus = func(x - dx);

        if (debug)
            fprintf('Итерация %d: [x=%12.10f, f=%12.10f]\n', iteration, x, f);
            plot(x, f, 'g.', 'MarkerSize', 15);
            iteration = iteration + 1;
        end

        x0 = x;

        f1 = (f_plus - f) / dx;
        f2 = (f_plus - 2 * f + f_minus) / (dx .^ 2);
        x = x - f1/f2;

        run = (abs(x - x0) > eps) || (abs(f1) > eps);
    end

    if (debug)
        fprintf('Итерация %d: [x=%12.10f, f=%12.10f]\n', iteration, x, f);
        plot(x, f, 'g.', 'MarkerSize', 15);
    end
end

function [xl, xr] = goldenSectionBoundaries(a, b)
    [~, ~, xl, xr] = goldenSectionSearch(a, b, 0.25, false);
end

function [x, f, x1, x2] = goldenSectionSearch(a, b, eps, debug)
    tau = (sqrt(5) - 1) / 2;
    delta = b - a;

    xl = b - tau * delta;
    xr = a + tau * delta;
    fl = func(xl);
    fr = func(xr);

    iteration = 1;
    while (delta > 2 * eps)
        if (debug)
            fprintf('Итерация %d: [a=%12.10f, b=%12.10f], (xl=%12.10f, xr=%12.10f)\n', iteration, a, b, xl, xr);
            iteration = iteration + 1;
        end

        if (fl > fr)
            a = xl;
            delta = b - a;
            xl = xr;
            fl = fr;
            xr = a + tau * delta;
            fr = func(xr);
        else
            b = xr;
            delta = b - a;
            xr = xl;
            fr = fl;
            xl = b - tau * delta;
            fl = func(xl);
        end
    end

    if (debug)
        fprintf('Итерация %d: [a=%12.10f, b=%12.10f], (xl=%12.10f, xr=%12.10f)\n', iteration, a, b, xl, xr);
    end

    x = (a + b) / 2;
    f = func(x);

    x1 = a;
    x2 = b;
end
