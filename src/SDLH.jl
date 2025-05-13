module SDLH
using Random,Base.Threads,Primes
export generateKey,writeKey

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

A secret key has both p and q prime. A public key has p semiprime and q=1.
"""
struct SDLHKey
  p	::BigInt
  q	::BigInt
  g	::UInt64
end

function generateKey(nbits::Integer)
  p=q=big(0)
  g=0
  while true
    p,q=bigSemiprime(nbits)
    for i in primes(2,16777213)
      if i<p && i<q && isGenerator(i,p,q)
        g=i
        break
      end
    end
    if g>0
      break
    end
  end
  SDLHKey(p,q,g)
end

function publicKey(key::SDLHKey)
  SDLHKey(key.p*key.q,1,key.g)
end

function isSecretKey(key::SDLHKey)
  isprime(key.q) && isprime(key.p)
end

function nBytes(n::Integer)
  (Base.top_set_bit(n)+7)÷8
end

function writeBigInt(file::IOStream,n::BigInt)
  nb=UInt32(nBytes(n))
  write(file,hton(nb))
  for i in 0:nb-1
    write(file,UInt8(n>>(i*8)&255))
  end
end

function writeKey(file::IOStream,key::SDLHKey)
  sec=isSecretKey(key)
  if sec
    write(file,"SDLHsec")
  else
    write(file,"SDLHpub")
  end
  writeBigInt(file,key.p)
  if sec
    writeBigInt(file,key.q)
  end
  write(file,hton(key.g))
end

function writeKey(fileName::String,key::SDLHKey)
  file=open(fileName,"w")
  writeKey(file,key)
  close(file)
end

end # module SDLH
