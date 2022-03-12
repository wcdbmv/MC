function lab01
    debug = true;

    a = 0;
    b = 1;
    eps = 1e-2;

    fplot(@(x) func(x), [a, b], 'b');
    hold on;

    global N;
    N = 0;

    [x, f] = radixSearch(a, b, eps, debug);
    fprintf('Минимум функции: (x=%10.8f, f=%10.8f)\n', x, f);
    fprintf('N = %d\n', N);

    p = plot(x, f, 'rx', 'MarkerSize', 15);
    legend((p), 'Метод поразрядного поиска', 'Location', 'northwest');

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

function [x, f] = radixSearch(a, b, eps, debug)
    delta = (b - a) / 4;
    x0 = a;
    f0 = func(x0);

    iteration = 1;
    run = true;
    while (run)
        if (debug)
            fprintf('Итерация %d: (x=%10.8f, f=%10.8f)\n', iteration, x0, f0);
            iteration = iteration + 1;
            plot(x0, f0, 'k.', 'MarkerSize', 15);
        end

        x1 = x0 + delta;
        f1 = func(x1);
        if (f0 > f1)
            x0 = x1;
            f0 = f1;
            if (a < x0 && x0 < b)
                continue;
            end
        end
        if (abs(delta) <= eps)
            run = false;
        else
            x0 = x1;
            f0 = f1;
            delta = -delta / 4;
        end
    end

    x = x0;
    f = f0;
end
