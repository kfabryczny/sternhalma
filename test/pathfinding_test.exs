defmodule PathfindingTest do
  use ExUnit.Case, async: true
  doctest Sternhalma.Pathfinding, import: true

  alias Sternhalma.{
    Board,
    Cell,
    Hex,
    Pathfinding
  }

  defp setup_board(occupied_locations) do
    Enum.map(Board.empty(), fn cell ->
      if Enum.any?(occupied_locations, fn point ->
           cell.position == Hex.from_pixel(point)
         end) do
        Cell.set_marble(cell, 'a')
      else
        cell
      end
    end)
  end

  test "finds jumpable neighbors" do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o x o o o o o o
    #     o x x s x o o o o
    #    o o o o o o o o o o
    #   o o o o o o o o o o o
    #  o o o o o o o o o o o o
    # o o o o o o o o o o o o o
    #          o o o o
    #           o o o
    #            o o
    #             o
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({8.268, 13})}

    board =
      setup_board([
        {10, 13},
        {6.536, 13},
        {4.804, 13},
        {7.402, 14.5}
      ])

    assert Pathfinding.jumpable_neighbors(start.position, board) == [
             %Cell{marble: nil, position: Hex.from_pixel({6.536, 16})},
             %Cell{marble: nil, position: Hex.from_pixel({11.732, 13})}
           ]
  end

  test "finds path to a neighboring cell" do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o o o o o o o o o o
    #  o o o o o o o o o o o o
    # o o o o o o o o o o o o o
    #          o s o o
    #           o f o
    #            o o
    #             o
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({9.134, 5.5})}
    finish = %Cell{position: Hex.from_pixel({10, 4})}
    board = setup_board([])

    assert Pathfinding.path(board, start, finish) == [
             start,
             finish
           ]
  end

  test "does not find path to a distant cell" do
    start = %Cell{marble: 'a', position: Hex.from_pixel({10, 1})}
    finish = %Cell{position: Hex.from_pixel({8.268, 4})}
    board = setup_board([{10, 1}])

    assert Pathfinding.path(board, start, finish) == []
  end

  test "does not find path to the same cell" do
    start = %Cell{marble: 'a', position: Hex.from_pixel({9.134, 5.5})}
    board = setup_board([{9.134, 5.5}])

    assert Pathfinding.path(board, start, start) == []
  end

  test "does not find path when the starting cell does not have a marble" do
    start = %Cell{marble: nil, position: Hex.from_pixel({9.134, 5.5})}
    finish = %Cell{position: Hex.from_pixel({10, 4})}
    board = setup_board([])

    assert Pathfinding.path(board, start, finish) == []
  end

  test "finds a path by jumping in a straight line", _state do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o f o o o o o o o o
    #  o o o x o o o o o o o o
    # o o o o o o o o o o o o o
    #          x o o o
    #           o o o
    #            x o
    #             s
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({10, 1})}
    finish = %Cell{position: Hex.from_pixel({4.804, 10})}
    board = setup_board([{9.134, 2.5}, {7.402, 5.5}, {5.67, 8.5}])

    assert Pathfinding.path(board, start, finish) == [
             start,
             %Cell{position: Hex.from_pixel({8.268, 4})},
             %Cell{position: Hex.from_pixel({6.536, 7})},
             finish
           ]
  end

  test "finds a path by jumping and changing directions", _state do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o o o o o o o o o o
    #  o o o o o o o o o o o o
    # o o o o o o f x o o o o o
    #          o o o x
    #           o x o
    #            x o
    #             s
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({10, 1})}
    finish = %Cell{position: Hex.from_pixel({10, 7})}
    board = setup_board([{9.134, 2.5}, {10, 4}, {12.598, 5.5}, {11.732, 7}])

    assert Pathfinding.path(board, start, finish) == [
             start,
             %Cell{position: Hex.from_pixel({8.268, 4})},
             %Cell{position: Hex.from_pixel({11.732, 4})},
             %Cell{position: Hex.from_pixel({13.464, 7})},
             finish
           ]
  end

  test "does not find path when jump not possible", _state do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o o o o o o o o o o
    #  o o o o o o o o o o o o
    # o o o o o o o o o o o o o
    #          o o o o
    #           o s o
    #            x x
    #             f
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({10, 4})}
    finish = %Cell{position: Hex.from_pixel({10, 1})}
    board = setup_board([{10, 4}, {9.134, 2.5}, {10.866, 2.5}])

    assert Pathfinding.path(board, start, finish) == []
  end

  test "does not find path when finishing cell is occupied", _state do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o o o o o o o o o o
    #  o o o o o o o o o o o o
    # o o o o o f o o o o o o o
    #          o x o o
    #           o s o
    #            o o
    #             o
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({10, 4})}
    finish = %Cell{position: Hex.from_pixel({8.268, 7})}
    board = setup_board([{9.134, 5.5}, {8.268, 7}])

    assert Pathfinding.path(board, start, finish) == []
  end

  test "(11.7, 4) -> (10, 7) is valid", _state do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o o o o o o o o o o
    #  o o o o o o o o o o o o
    # o o o o o o f o o o o o o
    #          o o x x
    #           o o s
    #            o o
    #             o
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({11.732, 4})}
    finish = %Cell{position: Hex.from_pixel({10, 7})}
    board = setup_board([{12.5, 5.5}, {10.866, 5.5}])

    assert Pathfinding.path(board, start, finish) == [
             start,
             finish
           ]
  end

  test "does not get stuck when there is a circular dependency", _state do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o s x o o o o f o
    #     o o o x x x x x o
    #    o o o o x o o o o o
    #   o o o o x x o o o o o
    #  o o o o o o o o o o o o
    # o o o o o o o o o o o o o
    #          o o o o
    #           o o o
    #            o o
    #             o
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({5.67, 14.5})}
    finish = %Cell{position: Hex.from_pixel({16.062, 14.5})}

    board =
      setup_board([
        {7.402, 14.5},
        {8.268, 13},
        {10, 13},
        {11.732, 13},
        {13.464, 13},
        {15.196, 13},
        {9.134, 11.5},
        {10, 10},
        {8.268, 10}
      ])

    path = Pathfinding.path(board, start, finish)

    assert path == [
             start,
             %Cell{marble: nil, position: Hex.from_pixel({9.134, 14.5})},
             %Cell{marble: nil, position: Hex.from_pixel({10.866, 11.5})},
             %Cell{marble: nil, position: Hex.from_pixel({12.598, 14.5})},
             %Cell{marble: nil, position: Hex.from_pixel({14.33, 11.5})},
             finish
           ]
  end
end
