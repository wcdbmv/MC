% Матрица стоимостей
C = [10 8 6 4 9; 11 9 10 5 6; 5 10 8 6 4; 3 11 9 6 6; 8 10 11 8 7]

% Проверим размеры матрицы
[width, height] = size(C);
if width ~= height
	disp('Матрица не квадратная!')
	return
end

n = width
if n == 0
	disp('Матрица нулевой размерности!')
	return
end

% Подготовительный этап:
% 1. Из каждого столбца матрицы вычитаем его наименьший элемент
minInColumns = min(C)
Ct = C - minInColumns
% 2. Из каждой строки матрицы вычитаем её наименьший элемент
minInRows = min(Ct, [], 2)
Ct = Ct - minInRows
% 3. Строим начальную СНН: просматриваем столбцы теушей матрицы стоимостей (в порядке возрастания номера столбца) сверху вниз. Первый в строке нуль, в одной строке с которым нет 0*, отмечаем 0*.
Stars = zeros(n);
colsBusy = zeros([1 n]); % Занятые столбцы
rowsBusy = zeros([n 1]); % Занятые строки
for col = 1:n
	for row = 1:n
		if Ct(row, col) == 0 && ~rowsBusy(row)
			Stars(row, col) = 1;
			rowsBusy(row) = 1;
			colsBusy(col) = 1;
			break;
		end
	end
end
Stars
% 4. k := |СНН|
k = sum(rowsBusy)

% Основной этап венгерского метода:
while k ~= n
	% Pluses =
end
