require 'csv'
require 'pry'

unless ARGV.length == 3
  puts "Sorry, incorrect number of arguments."
  puts "Usage: ruby parse.rb pointsFile.csv xValFiles.csv 'output_file_name'\n"
  exit
end

class Point
  attr_accessor :x, :y

  def initialize(x,y)
    @x = x
    @y = y
  end
end

def find_boundary_points(x_val, points)
  i = 0
  point = points[i]
  next_point = points[i + 1]

  while !next_point.nil? do
    if point.x <= x_val && x_val <= next_point.x

      boundary_points = Hash.new()
      boundary_points[:p1] = point
      boundary_points[:p2] = next_point
      return boundary_points
    else

    i = i + 1
    point = next_point
    next_point = points[i]
    end
  end
end


def get_y_value(p1, p2, x)
  # get slope
  m = (p2.y - p1.y)/ (p2.x - p1.x)

  # point slope form:  y - p1.y = m*(x - p1.x)
  # therefore: y = m*(x - p1.x) + p1.y
  #            y = m*x + m*p1.x + p1.y

  y_val = (m * x) - (m * p1.x) + p1.y
  return y_val
end


# parse input CSV files
point_csv = CSV.read(ARGV[0], "r:windows-1251:utf-8", headers: true, skip_blanks: true).
    reject { |row| row.to_hash.values.all?(&:nil?) }

x_val_csv = CSV.read(ARGV[1], "r:windows-1251:utf-8", headers: true, skip_blanks: true).
    reject { |row| row.to_hash.values.all?(&:nil?) }


# build points array
points = []
point_csv.each do |row|
  point = Point.new(row["x"].to_f, row["y"].to_f)
  points << point
end

# build x val array
x_vals = []
x_val_csv.each do |row|
  x_val = row["x"].to_f
  x_vals << x_val
end


# get y_vals
y_vals = []
x_vals.each do |x_val|
  # which two points does this x_val fall into?
  boundary_points = find_boundary_points(x_val, points)
  y_val = get_y_value(boundary_points[:p1], boundary_points[:p2], x_val)
  y_vals << y_val
end

# write to a file
file_location ="/Users/scarland/yesware_apps/corinne_script/#{ARGV[2]}.csv"

CSV.open(file_location, "wb") do |csv|
  (0..x_vals.length - 1).each do |i|
    csv << [x_vals[i], y_vals[i]]
  end
end



