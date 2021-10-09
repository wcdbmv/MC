function lab01
	% Режим работы
	debug = true;

	debug_disp = @(varargin) debug_generic(debug, @disp, varargin{:});
	debug_fprintf = @(varargin) debug_generic(debug, @fprintf, varargin{:});
	debug_disp_matrix = @(varargin) debug_generic(debug, @disp_matrix, varargin{:});

	% Матрица стоимостей
	C = [10   8   6   4   9;
	     11   9  10   5   6;
	      5  10   8   6   4;
	      3  11   9   6   6;
	      8  10  11   8   7];

	%C = [0 0 1 4;
	%     1 2 0 1;
	%     2 2 5 0;
	%     3 1 0 5];


	debug_disp('Матрица стоимостей:');
	debug_disp(C);

	% Проверка квадратности матрицы стоимостей
	[height, width] = size(C);
	if height ~= width
		disp('Матрица не квадратная!');
		return;
	end

	% Проверка размерности матрицы стоимостей
	n = height;
	if n == 0
		disp('Матрица нулевой размерности!');
		return;
	end


	debug_disp('[I] Подготовительный этап');
	debug_disp('1. Из каждого столбца матрицы вычитаем его наименьший элемент');

	minInColumns = min(C);
	Ct = C - minInColumns;

	debug_disp('Наименьшие элементы в столбцах матрицы стоимостей:');
	debug_disp(minInColumns);
	debug_disp('Эквивалентная матрица стоимостей:');
	debug_disp(Ct);


	debug_disp('2. Из каждой строки матрицы вычитаем её наименьший элемент');

	minInRows = min(Ct, [], 2);
	Ct = Ct - minInRows;

	debug_disp('Наименьшие элементы в строках матрицы стоимостей:');
	debug_disp(minInRows);
	debug_disp('Эквивалентная матрица стоимостей:');
	debug_disp(Ct);


	debug_disp('3. Строим начальную СНН:');
	debug_disp('просматриваем столбцы теушей матрицы стоимостей (в порядке возрастания номера столбца) сверху вниз.');
	debug_disp('Первый в строке нуль, в одной строке с которым нет 0*, отмечаем 0*.');

	stars = initStars(Ct, n);
	strokes = false(n);
	colsBusy = false([1 n]);
	rowsBusy = false([n 1]);

	debug_disp('Эквивалентная матрица стоимостей:');
	debug_disp_matrix(Ct, stars, strokes, colsBusy, rowsBusy);


	debug_disp('4. k := |СНН|');

	k = sum(stars, 'all');

	debug_fprintf('k = %d\n\n', k);


	debug_disp('[II] Основной этап венгерского метода');

	iteration = 1;
	while k ~= n
		debug_fprintf('-- Итерация %d\n', iteration);
		debug_disp('5. Столбцы с 0* отмечаем "+"');

		colsBusy = fillColsBusy(colsBusy, stars, n);

		debug_disp_matrix(Ct, stars, strokes, colsBusy, rowsBusy);


		runInnerWhile = true;
		while runInnerWhile
			runInnerWhile = false;
			runOuterWhile = false;
			h = Inf;
			for col = 1:n
				if colsBusy(col)
					continue;
				end

				for row = 1:n
					if rowsBusy(row)
						continue;
					end

					if Ct(row, col) == 0
						debug_disp("6. Среди невыделенных есть 0, отмечаем его 0':");

						strokes(row, col) = true;

						debug_disp_matrix(Ct, stars, strokes, colsBusy, rowsBusy);


						idx = find(stars(row, :), 1);
						if ~isempty(idx)
							debug_disp("7. В одной строке с текущим 0' есть 0*, поэтому");
							debug_disp("снимаем выделение со столбца с этим 0*, выделяем строку с этим 0'");

							colsBusy(idx) = false;
							rowsBusy(row) = true;

							debug_disp_matrix(Ct, stars, strokes, colsBusy, rowsBusy);
							runInnerWhile = true;
							break;
						end

						debug_disp("8. В одной строке с текущим 0' нет 0*, поэтому");
						debug_disp("строим непродолжаемую L-цепочку: от текущего 0' по столбцу в 0* по строке ... по строке в 0'");

						trow = row;
						tcol = col;
						Lchain = [trow tcol];
						Lrows = 1;
						trow = find(stars(:, tcol), 1);
						while ~isempty(trow)
							Lchain = [Lchain; trow tcol];
							tcol = find(strokes(trow, :), 1);
							Lchain = [Lchain; trow tcol];
							trow = find(stars(:, tcol), 1);
							Lrows = Lrows + 2;
						end

						debug_disp('L-цепочка [row col]:');
						debug_disp(Lchain);


						debug_disp("9. В пределах L-цепочки меняем 0* на 0, а 0' на 0*");

						for i = 1:2:Lrows
							x = Lchain(i, 1);
							y = Lchain(i, 2);
							strokes(x, y) = false;
							stars(x, y) = true;
						end

						for i = 2:2:Lrows-1
							x = Lchain(i, 1);
							y = Lchain(i, 2);
							stars(x, y) = false;
						end

						debug_disp_matrix(Ct, stars, strokes, colsBusy, rowsBusy);


						debug_disp("10. Снимаем все выделения, k := |СНН|");

						colsBusy(:) = false;
						rowsBusy(:) = false;

						debug_disp_matrix(Ct, stars, strokes, colsBusy, rowsBusy);
						runOuterWhile = true;
						break;
					elseif Ct(row, col) < h
						h = Ct(row, col);
					end
				end

				if runInnerWhile || runOuterWhile
					break;
				end
			end

			if ~runInnerWhile && ~runOuterWhile
				debug_disp('11. Среди невыделенных элементов нет 0, поэтому');
				debug_disp('ищем h — минимальный элемент среди невыделенных.');
				debug_fprintf('h = %d\n', h);

				debug_disp('Вычитаем h из невыделенных столбцов,');

				Ct(:, ~colsBusy) = Ct(:, ~colsBusy) - h;

				debug_disp(Ct);
				debug_disp('добавляем h к выделенным строкам');

				Ct(rowsBusy, :) = Ct(rowsBusy, :) + h;

				debug_disp(Ct);
			end
		end

		k = sum(stars, 'all');
		iteration = iteration + 1;
	end


	debug_fprintf('12. k = n = %d, записываем оптимальное решение\n', k);

	debug_disp('X =');
	debug_disp(stars);

	f = sum(C .* stars, 'all');
	debug_fprintf('f = %d\n', f);
end

function stars = initStars(Ct, n)
	stars = zeros(n);
	rowsBusy = false([n 1]);
	for col = 1:n
		for row = 1:n
			if Ct(row, col) == 0 && ~rowsBusy(row)
				stars(row, col) = 1;
				rowsBusy(row) = 1;
				break;
			end
		end
	end
end

function colsBusy = fillColsBusy(colsBusy, stars, n)
	for col = 1:n
		colsBusy(col) = ~isempty(find(stars(:, col), 1));
	end
end

function debug_generic(debug, func, varargin)
	if debug
		func(varargin{:});
	end
end

function disp_matrix(Ct, stars, strokes, colsBusy, rowsBusy)
	addition_symbols = [" ", "*", "'"];
	busy_symbols = [" ", "+"];
	[h, w] = size(Ct);
	for i = 1:h
		fprintf(' ');
		for j = 1:w
			fprintf('%5d', Ct(i, j));
			fprintf('%c', addition_symbols(1 + stars(i, j) + 2 * strokes(i, j)));
		end
		fprintf(' %c\n', busy_symbols(1 + rowsBusy(i)));
	end

	for j = 1:w
		fprintf('%6c', busy_symbols(1 + colsBusy(j)));
	end
	fprintf('\n');
end
