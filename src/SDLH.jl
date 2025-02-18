module SDLH
using Random,Base.Threads
export bigRand

rng=RandomDevice() # temporary

function bigRand(nbits::Integer)
  ret=big(0)
  while Base.top_set_bit(ret)<nbits
    ret=ret<<8+rand(rng,UInt8)
  end
  ret
end

end # module SDLH
