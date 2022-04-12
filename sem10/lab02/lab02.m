function lab02
    debug = true;

    a = 0;
    b = 1;
    eps = 1e-2;

    fplot(@(x) func(x), [a, b], 'b');
    hold on;

    global N;
    N = 0;

    [x, f] = goldenSectionSearch(a, b, eps, debug);
    fprintf('Минимум функции: (x=%10.8f, f=%10.8f)\n', x, f);
    fprintf('N = %d\n', N);

    p = plot(x, f, 'rx', 'MarkerSize', 15);
    legend((p), 'Метод золотого сечения', 'Location', 'northwest');

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

function [x, f] = goldenSectionSearch(a, b, eps, debug)
    tau = (sqrt(5) - 1) / 2;
    delta = b - a;

    xl = b - tau * delta;
    xr = a + tau * delta;
    fl = func(xl);
    fr = func(xr);

    iteration = 1;
    while (delta > 2 * eps)
        if (debug)
            fprintf('Итерация %d: [a=%10.8f, b=%10.8f], (xl=%10.8f, xr=%10.8f)\n', iteration, a, b, xl, xr);
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

    x = (a + b) / 2;
    f = func(x);
end
