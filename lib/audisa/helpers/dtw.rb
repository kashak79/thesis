class Helpers::Dtw
  Infinity = 1.0/0

  def match(sa, sb)

    a = sa.split(' ')
    b = sb.split(' ')

    if(a.size > b.size)
      tmp = b
      b = a
      a = tmp
    end

    raster = Array.new(a.size+1) { [0]*(b.size+1) }
    1.upto(b.size) { |i| raster[0][i] = Infinity}
    1.upto(a.size) { |i| raster[i][0] = Infinity}
    raster[0][0] = 0

    1.upto(b.size) do |i|
      1.upto(a.size) do |j|
        cost = distance(a[j-1],b[i-1])
        raster[j][i] = [99, raster[j][i-1], cost+raster[j-1][i-1]].min
      end
    end

    return raster[a.size][b.size]
  end

  def distance(a, b)
    if short(a) || short(b)
      a[0] == b[0] ? 0 : 1
    else
      1-a.jarowinkler_similar(b)
    end
  end

  def short(str)
    str.size == 1 || (str.size == 2 && str[1] == '.')
  end

end
