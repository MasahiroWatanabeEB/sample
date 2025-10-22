import SwiftUI

struct SudokuCell: Identifiable {
    let id = UUID()
    var row: Int
    var column: Int
    var value: Int?
    var isGiven: Bool
}

struct SudokuBoard {
    var cells: [[SudokuCell]]

    init(puzzle: [[Int?]] = SudokuBoard.defaultPuzzle) {
        cells = (0..<9).map { row in
            (0..<9).map { column in
                let value: Int?
                if row < puzzle.count, column < puzzle[row].count {
                    value = puzzle[row][column]
                } else {
                    value = nil
                }

                return SudokuCell(
                    row: row,
                    column: column,
                    value: value,
                    isGiven: value != nil
                )
            }
        }
    }

    func cell(at row: Int, column: Int) -> SudokuCell {
        cells[row][column]
    }

    mutating func setValue(_ value: Int?, at row: Int, column: Int) {
        guard cells.indices.contains(row), cells[row].indices.contains(column) else { return }
        guard !cells[row][column].isGiven else { return }
        cells[row][column].value = value
    }

    private static let defaultPuzzle: [[Int?]] = [
        [5, 3, nil, nil, 7, nil, nil, nil, nil],
        [6, nil, nil, 1, 9, 5, nil, nil, nil],
        [nil, 9, 8, nil, nil, nil, nil, 6, nil],
        [8, nil, nil, nil, 6, nil, nil, nil, 3],
        [4, nil, nil, 8, nil, 3, nil, nil, 1],
        [7, nil, nil, nil, 2, nil, nil, nil, 6],
        [nil, 6, nil, nil, nil, nil, 2, 8, nil],
        [nil, nil, nil, 4, 1, 9, nil, nil, 5],
        [nil, nil, nil, nil, 8, nil, nil, 7, 9]
    ]
}

struct ContentView: View {
    @State private var board = SudokuBoard()
    @State private var selectedPosition: (row: Int, column: Int)?

    var body: some View {
        VStack(spacing: 24) {
            Text("数独")
                .font(.largeTitle)
                .bold()

            SudokuBoardView(cells: board.cells, selectedPosition: selectedPosition) { row, column in
                guard !board.cells[row][column].isGiven else { return }
                selectedPosition = (row, column)
            }
            .padding()

            NumberPadView(selectedValue: currentSelectedValue) { number in
                guard let position = selectedPosition else { return }
                board.setValue(number, at: position.row, column: position.column)
            } onClear: {
                guard let position = selectedPosition else { return }
                board.setValue(nil, at: position.row, column: position.column)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct SudokuBoardView: View {
    var cells: [[SudokuCell]]
    var selectedPosition: (row: Int, column: Int)?
    var onSelect: (Int, Int) -> Void

    private let gridColumns = Array(repeating: GridItem(.fixed(36), spacing: 0), count: 9)

    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 0) {
            ForEach(0..<9, id: \.self) { row in
                ForEach(0..<9, id: \.self) { column in
                    let cell = cells[row][column]
                    SudokuCellView(
                        cell: cell,
                        isSelected: selectedPosition?.row == row && selectedPosition?.column == column
                    )
                    .onTapGesture {
                        onSelect(row, column)
                    }
                }
            }
        }
        .padding(12)
        .overlay(
            SudokuBoardGridLines()
                .padding(12)
                .allowsHitTesting(false)
        )
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.25), lineWidth: 1)
        )
    }
}

struct SudokuCellView: View {
    var cell: SudokuCell
    var isSelected: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 6, style: .continuous)

        ZStack {
            shape
                .fill(cellBackground)

            if isSelected {
                shape
                    .strokeBorder(Color.accentColor, lineWidth: 3)
                    .background(shape.fill(Color.accentColor.opacity(0.12)))
            }

            if let value = cell.value {
                Text("\(value)")
                    .font(.title3)
                    .fontWeight(cell.isGiven ? .bold : .regular)
                    .foregroundStyle(cell.isGiven ? Color.primary : Color.accentColor)
            }
        }
        .frame(width: 36, height: 36)
    }

    private var cellBackground: Color {
        cell.isGiven ? Color.primary.opacity(0.05) : Color.clear
    }
}

struct SudokuBoardGridLines: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let cellWidth = width / 9
            let cellHeight = height / 9

            ZStack {
                Path { path in
                    for index in 0...9 {
                        let x = cellWidth * CGFloat(index)
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))
                    }

                    for index in 0...9 {
                        let y = cellHeight * CGFloat(index)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                }
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)

                Path { path in
                    for index in stride(from: 0, through: 9, by: 3) {
                        let x = cellWidth * CGFloat(index)
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))
                    }

                    for index in stride(from: 0, through: 9, by: 3) {
                        let y = cellHeight * CGFloat(index)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                }
                .stroke(Color.primary.opacity(0.35), lineWidth: 2)
            }
        }
    }
}

struct NumberPadView: View {
    var selectedValue: Int?
    var onSelectNumber: (Int) -> Void
    var onClear: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 44, maximum: 60))]

    var body: some View {
        VStack(spacing: 12) {
            Text("数字を入力")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(1..<10) { number in
                    Button(action: {
                        onSelectNumber(number)
                    }) {
                        Text("\(number)")
                            .font(.headline)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(number == selectedValue ? Color.accentColor : Color.accentColor.opacity(0.12))
                            )
                            .foregroundStyle(number == selectedValue ? Color.white : Color.accentColor)
                    }
                }

                Button(action: onClear) {
                    Image(systemName: "delete.left")
                        .font(.headline)
                        .frame(width: 44, height: 44)
                        .foregroundStyle(Color.red)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.12)))
                }
                .accessibilityLabel("クリア")
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}

extension ContentView {
    private var currentSelectedValue: Int? {
        guard let position = selectedPosition else { return nil }
        return board.cells[position.row][position.column].value
    }
}

#Preview {
    ContentView()
}
