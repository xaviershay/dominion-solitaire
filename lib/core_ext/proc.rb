class Proc
  def &(other)
    lambda {|*args| self[*args] && other[*args] }
  end
end
