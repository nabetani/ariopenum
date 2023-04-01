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


def exps
  m=Hash.new{ |h,k| h[k]=[] }
  n=nums
  exps_impl( true, %w(a b c d) ) do |x|
    m[evalexp(x,*n)].push x
  end
  File.open( "exps.rb", "w" ) do |f|
    f.puts( "def exps(a,b,c,d)" )
    f.puts( "  [" )
    m.values.each do |e| 
      f.puts "    " + e.max_by{ |x| x.count("+") + x.count("*") - x.count("-") + x.count("/")  }+","
    end
    f.puts( "  ]" )
    f.puts( "end" )
  end
  pp m.size
end



exps
require "./exps.rb"

