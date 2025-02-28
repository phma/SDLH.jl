module SDLH
using Random,Base.Threads,Primes
export bigPrime

rng=RandomDevice()

function bigRand(nbits::Integer)
  ret=big(0)
  while Base.top_set_bit(ret)<nbits
    ret=ret<<8+rand(rng,UInt8)
  end
  ret
end

function arithProgPrime(a::T,b::T) where T<:Integer
  while !isprime(a)
    a+=b
  end
  a
end

function bigAnyPrime(nbits::Integer)
  a=bigRand(nbits)
  b=0x0000
  while gcd(a,b)!=1
    b=rand(rng,UInt16)
  end
  arithProgPrime(a,big(b))
end

function bigPrime(nbits::Integer)
  ret=big(0)
  while ret==0
    bigFactor=bigAnyPrime(nbits)
    for i in 2:2:512
      ret=bigFactor*i+1
      if isprime(ret)
	break
      end
      ret=big(0)
    end
  end
  ret
end

end # module SDLH
