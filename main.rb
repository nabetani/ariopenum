def nums
  g=->(){ rand(1<<64)+(2r**64) }
  Array.new(4){ g[]/g[] }
end

def newterm(a,b,op)
  ["(#{a}#{op}#{b})"]
end

def exps_impl(root, terms, &proc )
  if terms.size==1
    proc[terms[0]]
    return
  end
  if root
    (2..terms.size).each do |len|
      terms.permutation(len) do |n|
        rest = terms - n
        exps_impl(false, rest + ["digit(#{n.join(",")})"], &proc)
      end
    end
  end

  terms.combination(2) do |a,b|
    rest = terms - [a,b]
    exps_impl(false, rest + newterm(a,b,"+"), &proc)
    exps_impl(false, rest + newterm(a,b,"-"), &proc)
    exps_impl(false, rest + newterm(a,b,"*"), &proc)
    exps_impl(false, rest + newterm(a,b,"/"), &proc)
    exps_impl(false, rest + newterm(b,a,"-"), &proc)
    exps_impl(false, rest + newterm(b,a,"/"), &proc)
  end
end

def digit(*a)
  a.inject{ |acc,n|    acc*10 + n  }
end

def evalexp(ex,a,b,c,d)
  eval(ex).abs
end


def make_exps
  m=Hash.new{ |h,k| h[k]=[] }
  n=nums
  exps_impl( true, %w(a b c d) ) do |x|
    key = evalexp(x,*n)
    m[key].push x if key
  end
  File.open( "exps.rb", "w" ) do |f|
    f.puts( "def exps(a,b,c,d)" )
    f.puts( "  {" )
    m.values.each do |e| 
      best = e.max_by{ |x| x.count("+") + x.count("*") - x.count("-") + x.count("/")  }
      f.puts "    (#{best}.abs rescue nil)=>true,"
    end
    f.puts( "  }" )
    f.puts( "end" )
  end
  pp m.size
end

def score(n)
  values = exps(*n)
  (0...).find{ |x| !values[x.to_r] }-1
end

def main
  scores=[]
  [*0..9].map(&:to_r).repeated_combination(4) do |n|
    scores.push( [score(n), n] )
  end
  prev_m=nil
  prev_ord=nil
  scores.sort.reverse.take(12).each.with_index(1) do |(m,d),ix|
    ord = prev_m==m ? prev_ord : ix
    unless prev_m==m
      prev_ord = ix 
      prev_m = m
    end
    puts "|#{ord}|#{m}|#{d.map(&:to_i).join(",")}|"
  end
  # p exps(1,2,5,8).keys.select{ |x| x && x==x.to_i }.map(&:to_i ).sort.uniq.take(100)
end

make_exps
require "./exps.rb"
main

