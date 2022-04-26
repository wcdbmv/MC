function lab02
    clc;
    debug = true;

    a = 0;
    b = 1;
    eps = 1e-6;

    fplot(@(x) func(x), [a, b], 'b');
    hold on;

    global N;
    N = 0;

    [x, f] = goldenSectionSearch(a, b, eps, debug);
    fprintf('Минимум функции: (x=%10.10f, f=%10.10f)\n', x, f);
    fprintf('N = %d\n', N);
    x - 0.777

    p = plot(x, f, 'rx', 'MarkerSize', 15);
    legend((p), 'Метод золотого сечения', 'Location', 'northwest');

    hold off;
end

function y = func(x)
    global N;
    N = N + 1;

    y = (x - 0.777) .^ 14;

%     x3 = power(x, 3);
%     x2 = power(x, 2);
%     sqrt2 = sqrt(2);
%
%     ch = cosh((3 * x3 + 2 * x2 - 4 * x + 5) / 3);
%     th = tanh((x3 - 3 * sqrt2 * x - 2) / (2 * x + sqrt2));
%
%     y = ch + th - 2.5;
end

function [x, f] = goldenSectionSearch(a, b, eps, debug)
    tau = (sqrt(5) - 1) / 2;
    delta = b - a;

    xl = b - tau * delta;
    xr = a + tau * delta;
    fl = func(xl);
    fr = func(xr);

    iteration = 1;
    colors = ['k', 'r', 'b'];

    if debug
        fprintf('Итерация %d: [a=%10.10f, b=%10.10f], (xl=%10.10f, xr=%10.10f)\n', iteration, a, b, xl, xr);
        plot([xl xr], [fl fr], colors(1 + mod(iteration - 1, 3)));
        plot(xl, fl, 'k.', 'MarkerSize', 10);
        plot(xr, fr, 'k.', 'MarkerSize', 10);
        iteration = iteration + 1;
    end

    while delta > 2 * eps
        if fl > fr
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

        if debug
            fprintf('Итерация %d: [a=%10.10f, b=%10.10f], (xl=%10.10f, xr=%10.10f)\n', iteration, a, b, xl, xr);
            plot([xl xr], [fl fr], colors(1 + mod(iteration - 1, 3)));
            plot(xl, fl, 'k.', 'MarkerSize', 10);
            plot(xr, fr, 'k.', 'MarkerSize', 10);
            iteration = iteration + 1;
        end
    end

    x = (a + b) / 2;
    f = func(x);
end
