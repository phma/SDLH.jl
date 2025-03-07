module SDLH
using Random,Base.Threads,Primes
export bigSemiprime

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

function bigSemiprime(nbits::Integer)
  # Returns two primes. If nbits<28, it's likely that b will be 5.
  a=big(0)
  b=big(0)
  while true
    a=bigPrime(nbits÷2)
    b=bigPrime(nbits-Base.top_set_bit(a))
    if (a-b)^2>a+b
      break
    end
  end
  a,b
end

function isGenerator(g::Integer,p::Integer,q::Integer)
  totient=lcm(p-1,q-1)
  a=b=0
  for i in 2:2:512
    if p%i==1
      a=i
    end
  end
  for i in 2:2:512
    if q%i==1
      b=i
    end
  end
  factors=[p÷a,q÷b]
  for i in primes(2,509)
    if a%i==0 || b%i==0
      push!(factors,big(i))
    end
  end
  m=p*q
  ret=powermod(g,totient,q)==1
  for i in factors
    ret&=powermod(g,totient÷i,m)!=1
  end
  ret
end

"""
    struct SDLHKey

An SDLH key is similar to an RSA key, having two large primes whose product
is the modulus; but unlike an RSA key, which has an exponent to which a message
is raised, an SDLH key has a generator, and the message is the power to which
the generator is raised.
"""
struct SDLHKey
  p	::BigInt
  q	::BigInt
  g	::BigInt
end

end # module SDLH
