#!/usr/bin/env ruby

# -- (row, col) = (m, n)
$m = 4
$n = 4

# -- path mark map
$s_marks = Array.new($m * $n, "-")
# -- cost from S to X
$g_score = Array.new($m * $n, 1.0e7)
# -- g(X) + h(X)
$f_score = Array.new($m * $n, 1.0e7)

$came_from = Array.new($m * $n, nil)

class Array
  def get_min_node
    min_node = self[0]
    min_val  = $f_score[ min_node ]
    self.each {|el|
      if $f_score[el] < min_val then
        min_val  = $f_score[el]
        min_node = el
      end
    }
    min_node
  end

  def find(q)
    return q if self.select {|m| m == q }.size > 0
    return nil
  end
end

class Integer
  def get_neighbors
    neighbors = []
    [ [0, 1], [0, -1], [1, 0], [-1, 0] ].each {|dy, dx|
      query_row = self / $n + dy
      query_col = self % $n + dx
      next if query_row < 0 || query_row >= $m
      next if query_col < 0 || query_col >= $n

      neighbors << (self + dy * $n + dx)
    }
    return neighbors
  end
end

def dist_between(a, b)
  (a % $n - b % $n).abs + (a / $n - b / $n).abs
end

def heuristic_cost_estimate(a, b)
  return 1.0e7 if $s_marks[a] == "X" || $s_marks[b] == "X"
  dist_between(a, b)
end

def reconstruct_path(came_from, current_node)
  if came_from[current_node] then
    path_arr = reconstruct_path(came_from, came_from[current_node])
    path_arr << current_node
    return path_arr
  else
    return [ current_node ]
  end
end

# -- core func
def astar (start, goal)
  # -- init search set
  closed_set = []
  open_set   = []

  # -- set start cost
  open_set << start
  $g_score[start] = 0
  $f_score[start] = $g_score[start] + heuristic_cost_estimate(start, goal)

  # -- search
  while open_set.size > 0
    #p open_set
    current = open_set.get_min_node

    # -- X == G : end
    return reconstruct_path($came_from, goal) if current == goal

    # -- X != G : search neighbors
    open_set.delete(current)
    closed_set << current

    current.get_neighbors.each {|nb|
      next if closed_set.find(nb)
      tentative_g_score = $g_score[current] + dist_between(current, nb)
      #p nb.to_s + ","  + tentative_g_score.to_s

      if ( !open_set.find(nb) && tentative_g_score < $g_score[nb] ) then
        open_set << nb
        $came_from[nb] = current
        $g_score[nb]   = tentative_g_score

        $f_score[nb] = $g_score[nb] + heuristic_cost_estimate(nb, goal)
      end

    }
  end

  nil
end


# -- set start "S", goal "G"
start = 3
goal  = 15
$s_marks [start] = "S"
$s_marks [goal]  = "G"

# -- set hazard "X"
$s_marks [6]  = "X"
$s_marks [7]  = "X"
$s_marks [9]  = "X"
$s_marks [10]  = "X"
path = astar(start, goal)

# -- @debug : print path
p path
path.each {|pt|
  next if (pt == start || pt == goal)
  $s_marks[pt] = "."
}
$s_marks.each_with_index {|el, i|
  print el + ","
  puts if i % $n == $n - 1
}
